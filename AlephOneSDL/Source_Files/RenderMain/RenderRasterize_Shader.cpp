/*
 *  RenderRasterize_Shader.cpp
 *  Created by Clemens Unterkofler on 1/20/09.
 *  for Aleph One
 *
 *  http://www.gnu.org/licenses/gpl.html
 */

#include "OGL_Headers.h"

#include <iostream>

#include "RenderRasterize_Shader.h"

#include "lightsource.h"
#include "media.h"
#include "player.h"
#include "weapons.h"
#include "AnimatedTextures.h"
#include "OGL_Faders.h"
#include "OGL_Textures.h"
#include "OGL_Shader.h"
#include "ChaseCam.h"
#include "preferences.h"

#include "MatrixStack.hpp"
#include "AlephOneHelper.h"


#define MAXIMUM_VERTICES_PER_WORLD_POLYGON (MAXIMUM_VERTICES_PER_POLYGON+4)

inline bool FogActive();

class Blur {

private:
	FBOSwapper _swapper;
	Shader *_shader_blur;
	Shader *_shader_bloom;

public:

	Blur(GLuint w, GLuint h, Shader* s_blur, Shader* s_bloom)
	: _swapper(w, h, Bloom_sRGB), _shader_blur(s_blur), _shader_bloom(s_bloom) {}

	void begin() {
		_swapper.activate();
		glDisable(GL_FRAMEBUFFER_SRGB_EXT); // don't blend for initial
	}

	void end() {
		_swapper.swap();
	}

	void draw(FBOSwapper& dest) {
    glPushGroupMarkerEXT(0, "Draw Blur");
    
		int passes = _shader_bloom->passes();
		if (passes < 0)
      passes = 5;
    
    GLfloat modelProjection[16];
    MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);

		glBlendFunc(GL_SRC_ALPHA,GL_ONE);
		for (int i = 0; i < passes; i++) {
      glPushGroupMarkerEXT(0, "Blur Phase");
			_shader_blur->enable();
      _shader_blur->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);

			_shader_blur->setFloat(Shader::U_OffsetX, 1);
			_shader_blur->setFloat(Shader::U_OffsetY, 0);
			_shader_blur->setFloat(Shader::U_Pass, i + 1);
			_swapper.filter(false);

			_shader_blur->setFloat(Shader::U_OffsetX, 0);
			_shader_blur->setFloat(Shader::U_OffsetY, 1);
			_shader_blur->setFloat(Shader::U_Pass, i + 1);
			_swapper.filter(false);
      glPopGroupMarkerEXT();
      
      glPushGroupMarkerEXT(0, "Bloom Phase");
			_shader_bloom->enable();
      _shader_bloom->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);

			_shader_bloom->setFloat(Shader::U_Pass, i + 1);
//			if (Bloom_sRGB)
//				dest.blend(_swapper.current_contents(), true);
//			else
				dest.blend_multisample(_swapper.current_contents());
			
			Shader::disable();
      glPopGroupMarkerEXT();
		}
		
		glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    glPopGroupMarkerEXT();
	}
};


/*
 * initialize some stuff
 * happens once after opengl, shaders and textures are setup
 */
void RenderRasterize_Shader::setupGL(Rasterizer_Shader_Class& Rasterizer) {

	RasPtr = &Rasterizer;

	Shader::loadAll();

	Shader* s_blur = Shader::get(Shader::S_Blur);
	Shader* s_bloom = Shader::get(Shader::S_Bloom);

	blur.reset();
	if(TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_Blur)) {
		if(s_blur && s_bloom) {
			blur.reset(new Blur(640., 640. * graphics_preferences->screen_mode.height / graphics_preferences->screen_mode.width, s_blur, s_bloom));
		}
	}
	
//	glDisable(GL_CULL_FACE);
//	glDisable(GL_LIGHTING);
}

/*
 * override for RenderRasterizerClass::render_tree()
 *
 * with multiple rendering passes for glow effect
 */
const double TWO_PI = 8*atan(1.0);
const float AngleConvert = TWO_PI/float(FULL_CIRCLE);

void RenderRasterize_Shader::render_tree() {

	weaponFlare = PIN(view->maximum_depth_intensity - NATURAL_LIGHT_INTENSITY, 0, FIXED_ONE)/float(FIXED_ONE);
	selfLuminosity = PIN(NATURAL_LIGHT_INTENSITY, 0, FIXED_ONE)/float(FIXED_ONE);

	Shader* s = Shader::get(Shader::S_Invincible);
	s->enable();
	s->setFloat(Shader::U_Time, view->tick_count);
	s->setFloat(Shader::U_UseStatic, TEST_FLAG(Get_OGL_ConfigureData().Flags,OGL_Flag_FlatStatic) ? 0.0 : 1.0);
  
  s = Shader::get(Shader::S_Rect);
  s->enable();
  s->setFloat(Shader::U_Time, view->tick_count);
  
	s = Shader::get(Shader::S_InvincibleBloom);
	s->enable();
	s->setFloat(Shader::U_Time, view->tick_count);
	s->setFloat(Shader::U_UseStatic, TEST_FLAG(Get_OGL_ConfigureData().Flags,OGL_Flag_FlatStatic) ? 0.0 : 1.0);

	short leftmost = INT16_MAX;
	short rightmost = INT16_MIN;
	vector<clipping_window_data>& windows = RSPtr->RVPtr->ClippingWindows;
	for (vector<clipping_window_data>::const_iterator it = windows.begin(); it != windows.end(); ++it) {
		if (it->x0 < leftmost) {
			leftmost = it->x0;
			leftmost_clip = it->left;
		}
		if (it->x1 > rightmost) {
			rightmost = it->x1;
			rightmost_clip = it->right;
		}
	}
	
	bool usefog = false;
	int fogtype;
	OGL_FogData *fogdata;
	if (TEST_FLAG(Get_OGL_ConfigureData().Flags,OGL_Flag_Fog))
	{
		fogtype = (current_player->variables.flags&_HEAD_BELOW_MEDIA_BIT) ?
		OGL_Fog_BelowLiquid : OGL_Fog_AboveLiquid;
		fogdata = OGL_GetFogData(fogtype);
		if (fogdata && fogdata->IsPresent && fogdata->AffectsLandscapes) {
			usefog = true;
		}
	}
	s = Shader::get(Shader::S_Landscape);
	s->enable();
	s->setFloat(Shader::U_UseFog, usefog ? 1.0 : 0.0);
	s->setFloat(Shader::U_Yaw, view->yaw * AngleConvert);
	s->setFloat(Shader::U_Pitch, view->pitch * AngleConvert);
	s = Shader::get(Shader::S_LandscapeBloom);
	s->enable();
	s->setFloat(Shader::U_UseFog, usefog ? 1.0 : 0.0);
	s->setFloat(Shader::U_Yaw, view->yaw * AngleConvert);
	s->setFloat(Shader::U_Pitch, view->pitch * AngleConvert);
	Shader::disable();

	RenderRasterizerClass::render_tree(kDiffuse);

	if (useShaderPostProcessing() && TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_Blur) && blur.get()) {
		blur->begin();
		RenderRasterizerClass::render_tree(kGlow);
		blur->end();
		RasPtr->swapper->deactivate();
    glPushGroupMarkerEXT(0, "draw blur passes");
		blur->draw(*RasPtr->swapper);
    glPopGroupMarkerEXT();
		RasPtr->swapper->activate();
	}

	glAlphaFunc(GL_GREATER, 0.5);
}

void RenderRasterize_Shader::render_node(sorted_node_data *node, bool SeeThruLiquids, RenderStep renderStep)
{
	// parasitic object detection
    objectCount = 0;
    objectY = 0;
  
  RenderRasterizerClass::render_node(node, SeeThruLiquids, renderStep);

	// turn off clipping planes
  if (useShaderRenderer()) {
    MatrixStack::Instance()->disablePlane(0);
    MatrixStack::Instance()->disablePlane(1);
  } else {
    glDisable(GL_CLIP_PLANE0);
    glDisable(GL_CLIP_PLANE1);
  }
}

void RenderRasterize_Shader::clip_to_window(clipping_window_data *win)
{
    GLfloat clip[] = { 0., 0., 0., 0. };
        
    // recenter to player's orientation temporarily
  if (useShaderRenderer()){
    MatrixStack::Instance()->pushMatrix();
    MatrixStack::Instance()->translatef(view->origin.x, view->origin.y, 0.);
    MatrixStack::Instance()->rotatef(view->yaw * (360/float(FULL_CIRCLE)) + 90., 0., 0., 1.);
    MatrixStack::Instance()->rotatef(-0.1, 0., 0., 1.); // leave some excess to avoid artifacts at edges
  } else {
    glPushMatrix();
    glTranslatef(view->origin.x, view->origin.y, 0.);
    glRotatef(view->yaw * (360/float(FULL_CIRCLE)) + 90., 0., 0., 1.);
    
    glRotatef(-0.1, 0., 0., 1.); // leave some excess to avoid artifacts at edges
  }
	if (win->left.i != leftmost_clip.i || win->left.j != leftmost_clip.j) {
		clip[0] = win->left.i;
		clip[1] = win->left.j;
		
    if ( !useShaderRenderer() ){
      glEnable(GL_CLIP_PLANE0);
      glClipPlanef(GL_CLIP_PLANE0, clip);
    } else {
      MatrixStack::Instance()->enablePlane(0);
      MatrixStack::Instance()->clipPlanef(0, clip);
    }
	} else {
     if ( !useShaderRenderer() ){
       glDisable(GL_CLIP_PLANE0);
     } else {
       MatrixStack::Instance()->disablePlane(0);
     }
	}
  if (useShaderRenderer()){
    MatrixStack::Instance()->rotatef(0.2, 0., 0., 1.); // breathing room for right-hand clip
  } else {
    glRotatef(0.2, 0., 0., 1.); // breathing room for right-hand clip
  }
	if (win->right.i != rightmost_clip.i || win->right.j != rightmost_clip.j) {
		clip[0] = win->right.i;
		clip[1] = win->right.j;
    if ( !useShaderRenderer() ){
      glEnable(GL_CLIP_PLANE1);
      glClipPlanef(GL_CLIP_PLANE1, clip);
    }  else {
      MatrixStack::Instance()->enablePlane(1);
      MatrixStack::Instance()->clipPlanef(1, clip);
    }
	} else {
    if ( !useShaderRenderer() ){
      glDisable(GL_CLIP_PLANE1);
    } else {
      MatrixStack::Instance()->disablePlane(1);
    }
	}
  if (useShaderRenderer()){
    MatrixStack::Instance()->popMatrix();
  } else {
    glPopMatrix();
  }
}

void RenderRasterize_Shader::store_endpoint(
	endpoint_data *endpoint,
	long_vector2d& p)
{
	p.i = endpoint->vertex.x;
	p.j = endpoint->vertex.y;
}


TextureManager RenderRasterize_Shader::setupSpriteTexture(const rectangle_definition& rect, short type, float offset, RenderStep renderStep) {

	Shader *s = NULL;
	GLfloat color[3];
	GLfloat shade = PIN(static_cast<GLfloat>(rect.ambient_shade)/static_cast<GLfloat>(FIXED_ONE),0,1);
	color[0] = color[1] = color[2] = shade;

	TextureManager TMgr;

	TMgr.ShapeDesc = rect.ShapeDesc;
	TMgr.LowLevelShape = rect.LowLevelShape;
	TMgr.ShadingTables = rect.shading_tables;
	TMgr.Texture = rect.texture;
	TMgr.TransferMode = rect.transfer_mode;
	TMgr.TransferData = rect.transfer_data;
	TMgr.IsShadeless = (rect.flags&_SHADELESS_BIT) != 0;
	TMgr.TextureType = type;

	float flare = weaponFlare;

	//glEnable(GL_TEXTURE_2D); //DCW deprecated?
	//glColor4f(color[0], color[1], color[2], 1);
  MatrixStack::Instance()->color4f(color[0], color[1], color[2], 1);
  
	switch(TMgr.TransferMode) {
		case _static_transfer:
			TMgr.IsShadeless = 1;
			flare = -1;
			s = Shader::get(renderStep == kGlow ? Shader::S_InvincibleBloom : Shader::S_Invincible);
			s->enable();
			break;
		case _tinted_transfer:
			flare = -1;
			s = Shader::get(renderStep == kGlow ? Shader::S_InvisibleBloom : Shader::S_Invisible);
			s->enable();
			s->setFloat(Shader::U_Visibility, 1.0 - rect.transfer_data/32.0f);
			break;
		case _solid_transfer:
			//glColor4f(0,1,0,1);
      MatrixStack::Instance()->color4f(0,1,0,1);
			break;
		case _textured_transfer:
			if(TMgr.IsShadeless) {
				if (renderStep == kDiffuse) {
					//glColor4f(1,1,1,1);
          MatrixStack::Instance()->color4f(1,1,1,1);
				} else {
					//glColor4f(0,0,0,1);
          MatrixStack::Instance()->color4f(0,0,0,1);
				}
				flare = -1;
			}
			break;
		default:
			//glColor4f(0,0,1,1);
      MatrixStack::Instance()->color4f(0,0,1,1);
	}

	if(s == NULL) {
		s = Shader::get(renderStep == kGlow ? Shader::S_SpriteBloom : Shader::S_Sprite);
		s->enable();
	}

	if(TMgr.Setup()) {
		TMgr.RenderNormal();
	} else {
		TMgr.ShapeDesc = UNONE;
		return TMgr;
	}

  //DCW set texture filtering to make the 2d sampler show anything but black.
  /*glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);*/

  
	TMgr.SetupTextureMatrix();

	if (renderStep == kGlow) {
		s->setFloat(Shader::U_BloomScale, TMgr.BloomScale());
		s->setFloat(Shader::U_BloomShift, TMgr.BloomShift());
	}
	s->setFloat(Shader::U_Flare, flare);
	s->setFloat(Shader::U_SelfLuminosity, selfLuminosity);
	s->setFloat(Shader::U_Pulsate, 0);
	s->setFloat(Shader::U_Wobble, 0);
	s->setFloat(Shader::U_Depth, offset);
	s->setFloat(Shader::U_StrictDepthMode, OGL_ForceSpriteDepth() ? 1 : 0);
	s->setFloat(Shader::U_Glow, 0);
	return TMgr;
}

// Circle constants
const double Radian2Circle = 1/TWO_PI;			// A circle is 2*pi radians
const double FullCircleReciprocal = 1/double(FULL_CIRCLE);

TextureManager RenderRasterize_Shader::setupWallTexture(const shape_descriptor& Texture, short transferMode, float pulsate, float wobble, float intensity, float offset, RenderStep renderStep) {

	Shader *s = NULL;

	TextureManager TMgr;
	LandscapeOptions *opts = NULL;
	TMgr.ShapeDesc = Texture;
	if (TMgr.ShapeDesc == UNONE) { return TMgr; }
	get_shape_bitmap_and_shading_table(Texture, &TMgr.Texture, &TMgr.ShadingTables,
		current_player->infravision_duration ? _shading_infravision : _shading_normal);

	TMgr.TransferMode = _textured_transfer;
	TMgr.IsShadeless = current_player->infravision_duration ? 1 : 0;
	TMgr.TransferData = 0;

	float flare = weaponFlare;

  if( useShaderRenderer() ) {
    MatrixStack::Instance()->color4f(intensity, intensity, intensity, 1.0);
  } else {
      glEnable(GL_TEXTURE_2D);
      glColor4f(intensity, intensity, intensity, 1.0);
  }
	switch(transferMode) {
		case _xfer_static:
			TMgr.TextureType = OGL_Txtr_Wall;
			TMgr.TransferMode = _static_transfer;
			TMgr.IsShadeless = 1;
			flare = -1;
			s = Shader::get(renderStep == kGlow ? Shader::S_InvincibleBloom : Shader::S_Invincible);
			s->enable();
			break;
		case _xfer_landscape:
		case _xfer_big_landscape:
		{
			TMgr.TextureType = OGL_Txtr_Landscape;
			TMgr.TransferMode = _big_landscaped_transfer;
			opts = View_GetLandscapeOptions(Texture);
			TMgr.LandscapeVertRepeat = opts->VertRepeat;
			TMgr.Landscape_AspRatExp = opts->OGL_AspRatExp;
			s = Shader::get(renderStep == kGlow ? Shader::S_LandscapeBloom : Shader::S_Landscape);
			s->enable();
		}
			break;
		default:
			TMgr.TextureType = OGL_Txtr_Wall;
			if(TMgr.IsShadeless) {
				if (renderStep == kDiffuse) {
          if( useShaderRenderer() ) {
            MatrixStack::Instance()->color4f(1,1,1,1);
          } else {
            glColor4f(1,1,1,1);
          }
				} else {
          if( useShaderRenderer() ) {
            MatrixStack::Instance()->color4f(0,0,0,1);
          } else {
            glColor4f(0,0,0,1);
          }
				}
				flare = -1;
			}
	}

	if(s == NULL) {
		if(TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_BumpMap)) {
			s = Shader::get(renderStep == kGlow ? Shader::S_BumpBloom : Shader::S_Bump);
		} else {
			s = Shader::get(renderStep == kGlow ? Shader::S_WallBloom : Shader::S_Wall);
		}
		s->enable();
	}

	if(TMgr.Setup()) {
		TMgr.RenderNormal(); // must allocate first
		if (TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_BumpMap)) {
			glActiveTexture(GL_TEXTURE1);
			TMgr.RenderBump();
			glActiveTexture(GL_TEXTURE0);
		}
	} else {
		TMgr.ShapeDesc = UNONE;
		return TMgr;
	}

	TMgr.SetupTextureMatrix();
	
	if (TMgr.TextureType == OGL_Txtr_Landscape && opts) {
		double TexScale = ABS(TMgr.U_Scale);
		double HorizScale = double(1 << opts->HorizExp);
		s->setFloat(Shader::U_ScaleX, HorizScale * (npotTextures ? 1.0 : TexScale) * Radian2Circle);
		s->setFloat(Shader::U_OffsetX, HorizScale * (0.25 + opts->Azimuth * FullCircleReciprocal));
		
		short AdjustedVertExp = opts->VertExp + opts->OGL_AspRatExp;
		double VertScale = (AdjustedVertExp >= 0) ? double(1 << AdjustedVertExp)
		                                          : 1/double(1 << (-AdjustedVertExp));
		s->setFloat(Shader::U_ScaleY, VertScale * TexScale * Radian2Circle);
		s->setFloat(Shader::U_OffsetY, (0.5 + TMgr.U_Offset) * TexScale);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); //DCW added for landscape. Repeat horizontally
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);//DCW added for landscape. Mirror vertically.

  } else {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); //DCW this is probably better for non-landscapes
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);//DCW this is probably better for non-landscapes
  }
  
  //DCW set texture filtering. GL_LINEAR is needed for non-mipmapped landscapes.
  if ( TMgr.TextureType == OGL_Txtr_Landscape ) {
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  } else {
    //glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  }

	if (renderStep == kGlow) {
		if (TMgr.TextureType == OGL_Txtr_Landscape) {
			s->setFloat(Shader::U_BloomScale, TMgr.LandscapeBloom());
		} else {
			s->setFloat(Shader::U_BloomScale, TMgr.BloomScale());
			s->setFloat(Shader::U_BloomShift, TMgr.BloomShift());
		}
	}
	s->setFloat(Shader::U_Flare, flare);
	s->setFloat(Shader::U_SelfLuminosity, selfLuminosity);
	s->setFloat(Shader::U_Pulsate, pulsate);
	s->setFloat(Shader::U_Wobble, wobble);
	s->setFloat(Shader::U_Depth, offset);
	s->setFloat(Shader::U_Glow, 0);
	return TMgr;
}

void instantiate_transfer_mode(struct view_data *view, short transfer_mode, world_distance &x0, world_distance &y0) {
	short alternate_transfer_phase;
	short transfer_phase = view->tick_count;

	switch (transfer_mode) {

		case _xfer_fast_horizontal_slide:
		case _xfer_horizontal_slide:
		case _xfer_vertical_slide:
		case _xfer_fast_vertical_slide:
		case _xfer_wander:
		case _xfer_fast_wander:
			x0 = y0= 0;
			switch (transfer_mode) {
				case _xfer_fast_horizontal_slide: transfer_phase<<= 1;
				case _xfer_horizontal_slide: x0= (transfer_phase<<2)&(WORLD_ONE-1); break;

				case _xfer_fast_vertical_slide: transfer_phase<<= 1;
				case _xfer_vertical_slide: y0= (transfer_phase<<2)&(WORLD_ONE-1); break;

				case _xfer_fast_wander: transfer_phase<<= 1;
				case _xfer_wander:
					alternate_transfer_phase= transfer_phase%(10*FULL_CIRCLE);
					transfer_phase= transfer_phase%(6*FULL_CIRCLE);
					x0 = (cosine_table[NORMALIZE_ANGLE(alternate_transfer_phase)] +
						 (cosine_table[NORMALIZE_ANGLE(2*alternate_transfer_phase)]>>1) +
						 (cosine_table[NORMALIZE_ANGLE(5*alternate_transfer_phase)]>>1))>>(WORLD_FRACTIONAL_BITS-TRIG_SHIFT+2);
					y0 = (sine_table[NORMALIZE_ANGLE(transfer_phase)] +
						 (sine_table[NORMALIZE_ANGLE(2*transfer_phase)]>>1) +
						 (sine_table[NORMALIZE_ANGLE(3*transfer_phase)]>>1))>>(WORLD_FRACTIONAL_BITS-TRIG_SHIFT+2);
					break;
			}
			break;
		// wobble is done in the shader
		default:
			break;
	}
}

float calcWobble(short transferMode, short transfer_phase) {
	float wobble = 0;
	switch(transferMode) {
		case _xfer_fast_wobble:
			transfer_phase*= 15;
		case _xfer_pulsate:
		case _xfer_wobble:
			transfer_phase&= WORLD_ONE/16-1;
			transfer_phase= (transfer_phase>=WORLD_ONE/32) ? (WORLD_ONE/32+WORLD_ONE/64 - transfer_phase) : (transfer_phase - WORLD_ONE/64);
			wobble = transfer_phase / 1024.0;
			break;
	}
	return wobble;
}

void setupBlendFunc(short blendType) {
	switch(blendType)
	{
		case OGL_BlendType_Crossfade:
			glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
			break;
		case OGL_BlendType_Add:
			glBlendFunc(GL_SRC_ALPHA,GL_ONE);
			break;
		case OGL_BlendType_Crossfade_Premult:
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			break;
		case OGL_BlendType_Add_Premult:
			glBlendFunc(GL_ONE, GL_ONE);
			break;
	}
}

bool setupGlow(struct view_data *view, TextureManager &TMgr, float wobble, float intensity, float flare, float selfLuminosity, float offset, RenderStep renderStep) {
	if (TMgr.TransferMode == _textured_transfer && TMgr.IsGlowMapped()) {
		Shader *s = NULL;
		if (TMgr.TextureType == OGL_Txtr_Wall) {
			if (TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_BumpMap)) {
				s = Shader::get(renderStep == kGlow ? Shader::S_BumpBloom : Shader::S_Bump);
			} else {
				s = Shader::get(renderStep == kGlow ? Shader::S_WallBloom : Shader::S_Wall);
			}
		} else {
			s = Shader::get(renderStep == kGlow ? Shader::S_SpriteBloom : Shader::S_Sprite);
		}

		TMgr.RenderGlowing();
		setupBlendFunc(TMgr.GlowBlend());
		//Deprecated glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		//Deprecated glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.001);

		s->enable();
		if (renderStep == kGlow) {
			s->setFloat(Shader::U_BloomScale, TMgr.GlowBloomScale());
			s->setFloat(Shader::U_BloomShift, TMgr.GlowBloomShift());
		}
		s->setFloat(Shader::U_Flare, flare);
		s->setFloat(Shader::U_SelfLuminosity, selfLuminosity);
		s->setFloat(Shader::U_Wobble, wobble);
		s->setFloat(Shader::U_Depth, offset - 1.0);
		s->setFloat(Shader::U_Glow, TMgr.MinGlowIntensity());
		return true;
	}
	return false;
}

void RenderRasterize_Shader::render_node_floor_or_ceiling(clipping_window_data *window,
	polygon_data *polygon, horizontal_surface_data *surface, bool void_present, bool ceil, RenderStep renderStep) {

	float offset = 0;

	const shape_descriptor& texture = AnimTxtr_Translate(surface->texture);
	float intensity = get_light_intensity(surface->lightsource_index) / float(FIXED_ONE - 1);
	float wobble = calcWobble(surface->transfer_mode, view->tick_count);
	// note: wobble and pulsate behave the same way on floors and ceilings
	// note 2: stronger wobble looks more like classic with default shaders
	TextureManager TMgr = setupWallTexture(texture, surface->transfer_mode, wobble * 4.0, 0, intensity, offset, renderStep);

  //DCW set texture filtering. Don't clamp to edge here.
  //glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR );
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  
  if(TMgr.ShapeDesc == UNONE) { return; }

	if (TMgr.IsBlended()) {
		glEnable(GL_BLEND);
		setupBlendFunc(TMgr.NormalBlend());
		//glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.001);
	} else {
		glDisable(GL_BLEND);
		//glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.5);
	}

//	if (void_present) {
//		glDisable(GL_BLEND);
//		glDisable(GL_ALPHA_TEST);
//	}

	short vertex_count = polygon->vertex_count;

	if (vertex_count) {
        clip_to_window(window);

		world_distance x = 0.0, y = 0.0;
		instantiate_transfer_mode(view, surface->transfer_mode, x, y);

		vec3 N;
		vec3 T;
		float sign;
		if(ceil) {
			N = vec3(0,0,-1);
			T = vec3(0,1,0);
			sign = 1;
		} else {
			N = vec3(0,0,1);
			T = vec3(0,1,0);
			sign = -1;
		}
		glNormal3f(N[0], N[1], N[2]);
    MatrixStack::Instance()->normal3f(N[0], N[1], N[2]);

    GLfloat tex4[4] = {T[0], T[1], T[2], sign};
    
    //glMultiTexCoord4fARB(GL_TEXTURE1_ARB, T[0], T[1], T[2], sign); //DCW I don't think we have this ARB extension in iOS
    if( !useShaderRenderer() ){
      glMultiTexCoord4f(GL_TEXTURE1, T[0], T[1], T[2], sign);
    }
    
		GLfloat vertex_array[MAXIMUM_VERTICES_PER_POLYGON * 3];
    GLfloat texcoord_array[MAXIMUM_VERTICES_PER_POLYGON * 2];
    
		GLfloat* vp = vertex_array;
		GLfloat* tp = texcoord_array;
		if (ceil)
		{
			for(short i = 0; i < vertex_count; ++i) {
				world_point2d vertex = get_endpoint_data(polygon->endpoint_indexes[vertex_count - 1 - i])->vertex;
				*vp++ = vertex.x;
				*vp++ = vertex.y;
				*vp++ = surface->height;
				*tp++ = (vertex.x + surface->origin.x + x) / float(WORLD_ONE);
				*tp++ = (vertex.y + surface->origin.y + y) / float(WORLD_ONE);
			}
		}
		else
		{
			for(short i=0; i<vertex_count; ++i) {
				world_point2d vertex = get_endpoint_data(polygon->endpoint_indexes[i])->vertex;
				*vp++ = vertex.x;
				*vp++ = vertex.y;
				*vp++ = surface->height;
				*tp++ = (vertex.x + surface->origin.x + x) / float(WORLD_ONE);
				*tp++ = (vertex.y + surface->origin.y + y) / float(WORLD_ONE);
			}
		}
    if( useShaderRenderer() ){
      glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texcoord_array);
      glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
      
      glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vertex_array);
      glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
      
      glVertexAttribPointer(Shader::ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 0, MatrixStack::Instance()->normals());
      glEnableVertexAttribArray(Shader::ATTRIB_NORMAL);
    } else {
      glVertexPointer(3, GL_FLOAT, 0, vertex_array);
      glTexCoordPointer(2, GL_FLOAT, 0, texcoord_array);
    }
    
    Shader* lastShader = lastEnabledShader();
    if (lastShader) {
      GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16], media6[4];;
      MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
      MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
      MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
      MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
      MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
      MatrixStack::Instance()->getPlanev(6, media6);

      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
      lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
      lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
      lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
      lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
      lastShader->setVec4(Shader::U_TexCoords4, tex4);
      lastShader->setVec4(Shader::U_MediaPlane6, media6);
    }
    
    glPushGroupMarkerEXT(0, "render_node_floor_or_ceiling");
		glDrawArrays(GL_TRIANGLE_FAN, 0, vertex_count);
    glPopGroupMarkerEXT();

		if (setupGlow(view, TMgr, wobble, intensity, weaponFlare, selfLuminosity, offset, renderStep)) {
      glPushGroupMarkerEXT(0, "render_node_floor_or_ceiling glow setup");
			glDrawArrays(GL_TRIANGLE_FAN, 0, vertex_count);
      glPopGroupMarkerEXT();
		}

		Shader::disable();
		if (!useShaderRenderer()) glMatrixMode(GL_TEXTURE);
    MatrixStack::Instance()->matrixMode(MS_TEXTURE);
		if (!useShaderRenderer()) glLoadIdentity();
    MatrixStack::Instance()->loadIdentity();
		if (!useShaderRenderer()) glMatrixMode(GL_MODELVIEW);
    MatrixStack::Instance()->matrixMode(MS_MODELVIEW);
	}
}

void RenderRasterize_Shader::render_node_side(clipping_window_data *window, vertical_surface_data *surface, bool void_present, RenderStep renderStep) {

	float offset = 0;
	if (!void_present) {
		offset = -2.0;
	}

	const shape_descriptor& texture = AnimTxtr_Translate(surface->texture_definition->texture);
	float intensity = (get_light_intensity(surface->lightsource_index) + surface->ambient_delta) / float(FIXED_ONE - 1);
	float wobble = calcWobble(surface->transfer_mode, view->tick_count);
	float pulsate = 0;
	if (surface->transfer_mode == _xfer_pulsate) {
		pulsate = wobble;
		wobble = 0;
	}
	TextureManager TMgr = setupWallTexture(texture, surface->transfer_mode, pulsate, wobble, intensity, offset, renderStep);
	if(TMgr.ShapeDesc == UNONE) { return; }

	if (TMgr.IsBlended()) {
		glEnable(GL_BLEND);
		setupBlendFunc(TMgr.NormalBlend());
    if ( !useShaderRenderer()){
      glEnable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GREATER, 0.001);
    }
	} else {
		glDisable(GL_BLEND);
    if ( ! useShaderRenderer()){
      glEnable(GL_ALPHA_TEST);
      glAlphaFunc(GL_GREATER, 0.5);
    }
	}

//	if (void_present) {
//		glDisable(GL_BLEND);
//		glDisable(GL_ALPHA_TEST);
//	}

	world_distance h= MIN(surface->h1, surface->hmax);

	if (h>surface->h0) {

		world_point2d vertex[2];
		uint16 flags;
		flagged_world_point3d vertices[MAXIMUM_VERTICES_PER_WORLD_POLYGON];
		short vertex_count;

		/* initialize the two posts of our trapezoid */
		vertex_count= 2;
		long_to_overflow_short_2d(surface->p0, vertex[0], flags);
		long_to_overflow_short_2d(surface->p1, vertex[1], flags);

		if (vertex_count) {
            clip_to_window(window);

			vertex_count= 4;
			vertices[0].z= vertices[1].z= h + view->origin.z;
			vertices[2].z= vertices[3].z= surface->h0 + view->origin.z;
      vertices[0].x= vertices[3].x= vertex[0].x; vertices[0].y= vertices[3].y= vertex[0].y; //DCW changed , to ;
      vertices[1].x= vertices[2].x= vertex[1].x; vertices[1].y= vertices[2].y= vertex[1].y; //DCW changed , to ;
			vertices[0].flags = vertices[3].flags = 0;
			vertices[1].flags = vertices[2].flags = 0;

			double div = WORLD_ONE;
			double dx = (surface->p1.i - surface->p0.i) / double(surface->length);
			double dy = (surface->p1.j - surface->p0.j) / double(surface->length);

			world_distance x0 = WORLD_FRACTIONAL_PART(surface->texture_definition->x0);
			world_distance y0 = WORLD_FRACTIONAL_PART(surface->texture_definition->y0);

			double tOffset = surface->h1 + view->origin.z + y0;

			vec3 N(-dy, dx, 0);
			vec3 T(dx, dy, 0);
			float sign = 1;
      if (useShaderRenderer() ){
        MatrixStack::Instance()->normal3f(N[0], N[1], N[2]);
      } else {
        glNormal3f(N[0], N[1], N[2]);
      }
      
      GLfloat tex4[4] = {T[0], T[1], T[2], sign};

			//glMultiTexCoord4fARB(GL_TEXTURE1_ARB, T[0], T[1], T[2], sign); //DCW I don't think we have this ARB extension in iOS
      if( !useShaderRenderer() ){
        glMultiTexCoord4f(GL_TEXTURE1, tex4[0], tex4[1], tex4[2], tex4[3]);
      }
			world_distance x = 0.0, y = 0.0;
			instantiate_transfer_mode(view, surface->transfer_mode, x, y);

			x0 -= x;
			tOffset -= y;

      // DJB OpenGL covert code from quads
      GLfloat t[2][4], v[3][4];
      /*for(int i = 0; i < vertex_count; ++i) {
        float p2 = 0;
        if(i == 1 || i == 2) {
          p2 = surface->length;
        }
        t[0][i] = (tOffset - vertices[i].z) / div;
        t[1][i] = (x0+p2) / div;
        v[0][i] = vertices[i].x;
        v[1][i] = vertices[i].y;
        v[2][i] = vertices[i].z;
      }*/
      //DCW back port the original quad code, because it should work with fans:
      GLfloat vertex_array[12];
      GLfloat texcoord_array[8];
      GLfloat* vp = vertex_array;
      GLfloat* tp = texcoord_array;
      for(int i = 0; i < vertex_count; ++i) {
        float p2 = 0;
        if(i == 1 || i == 2) { p2 = surface->length; }
        *vp++ = vertices[i].x;
        *vp++ = vertices[i].y;
        *vp++ = vertices[i].z;
        *tp++ = (tOffset - vertices[i].z) / div;
        *tp++ = (x0+p2) / div;
      }
      
      if( useShaderRenderer() ){
        glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texcoord_array);
        glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
        
        glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vertex_array);
        glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
        
        glVertexAttribPointer(Shader::ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 0, MatrixStack::Instance()->normals());
        glEnableVertexAttribArray(Shader::ATTRIB_NORMAL);
      } else {
        glVertexPointer(3, GL_FLOAT, 0, vertex_array);
        glEnableClientState(GL_VERTEX_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, texcoord_array);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      }
      
      Shader* lastShader = lastEnabledShader();
      if (lastShader) {
        GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16], media6[4];
        MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
        MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
        MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
        MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
        MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
        MatrixStack::Instance()->getPlanev(6, media6);

        lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
        lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
        lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
        lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
        lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
        lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
        lastShader->setVec4(Shader::U_TexCoords4, tex4);
        lastShader->setVec4(Shader::U_MediaPlane6, media6);
      }
         
      glPushGroupMarkerEXT(0, "render_node_side");
      glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
      glPopGroupMarkerEXT();
			/*(GLfloat vertex_array[12];
			GLfloat texcoord_array[8];

			GLfloat* vp = vertex_array;
			GLfloat* tp = texcoord_array;

			for(int i = 0; i < vertex_count; ++i) {
				float p2 = 0;
				if(i == 1 || i == 2) { p2 = surface->length; }

				*vp++ = vertices[i].x;
				*vp++ = vertices[i].y;
				*vp++ = vertices[i].z;
				*tp++ = (tOffset - vertices[i].z) / div;
				*tp++ = (x0+p2) / div;
			}
			glVertexPointer(3, GL_FLOAT, 0, vertex_array);
			glTexCoordPointer(2, GL_FLOAT, 0, texcoord_array);
			
			glDrawArrays(GL_QUADS, 0, vertex_count);
       */
      
			if (setupGlow(view, TMgr, wobble, intensity, weaponFlare, selfLuminosity, offset, renderStep)) {
        // DJB OpenGL convert from quads
        //DCW I think the original behavior is fine.
        /*for(int i = 0; i < vertex_count; ++i) {
          float p2 = 0;
          if(i == 1 || i == 2) {
            p2 = surface->length;
          }
          t[0][i] = (tOffset - vertices[i].z) / div;
          t[1][i] = (x0+p2) / div;
          v[0][i] = vertices[i].x;
          v[1][i] = vertices[i].y;
          v[2][i] = vertices[i].z;
        }
        if( useShaderRenderer() ){
          glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, t);
          glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
          
          glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, v);
          glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
        } else {
          glVertexPointer(2, GL_FLOAT, 0, v);
          glEnableClientState(GL_VERTEX_ARRAY);
          glTexCoordPointer(2, GL_FLOAT, 0, t);
          glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        }*/
        glPushGroupMarkerEXT(0, "render_node_side glow");
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
        glPopGroupMarkerEXT();
        //glDrawArrays(GL_QUADS, 0, vertex_count);
			}

			Shader::disable();
			if (!useShaderRenderer()) glMatrixMode(GL_TEXTURE);
      MatrixStack::Instance()->matrixMode(MS_TEXTURE);
			if (!useShaderRenderer()) glLoadIdentity();
      MatrixStack::Instance()->loadIdentity();
			if (!useShaderRenderer()) glMatrixMode(GL_MODELVIEW);
      MatrixStack::Instance()->matrixMode(MS_MODELVIEW);

		}
	}
}

extern void FlatBumpTexture(); // from OGL_Textures.cpp

bool RenderModel(rectangle_definition& RenderRectangle, short Collection, short CLUT, float flare, float selfLuminosity, RenderStep renderStep) {

	OGL_ModelData *ModelPtr = RenderRectangle.ModelPtr;
	OGL_SkinData *SkinPtr = ModelPtr->GetSkin(CLUT);
	if(!SkinPtr) { return false; }

	if (ModelPtr->Sidedness < 0) {
		glEnable(GL_CULL_FACE);
		glFrontFace(GL_CCW);
	} else if (ModelPtr->Sidedness > 0) {
		glEnable(GL_CULL_FACE);
		glFrontFace(GL_CW);
	} else {
		glDisable(GL_CULL_FACE);
	}

	glEnable(GL_TEXTURE_2D);
	if (SkinPtr->OpacityType != OGL_OpacType_Crisp || RenderRectangle.transfer_mode == _tinted_transfer) {
		glEnable(GL_BLEND);
		setupBlendFunc(SkinPtr->NormalBlend);
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.001);
	} else {
		glDisable(GL_BLEND);
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.5);
	}

	GLfloat color[3];
	GLfloat shade = PIN(static_cast<GLfloat>(RenderRectangle.ambient_shade)/static_cast<GLfloat>(FIXED_ONE),0,1);
	color[0] = color[1] = color[2] = shade;
	//glColor4f(color[0], color[1], color[2], 1.0);
  MatrixStack::Instance()->color4f(color[0], color[1], color[2], 1.0);

	Shader *s = NULL;
	bool canGlow = false;
	switch(RenderRectangle.transfer_mode) {
		case _static_transfer:
			flare = -1;
			s = Shader::get(renderStep == kGlow ? Shader::S_InvincibleBloom : Shader::S_Invincible);
			s->enable();
			break;
		case _tinted_transfer:
			flare = -1;
			s = Shader::get(renderStep == kGlow ? Shader::S_InvisibleBloom : Shader::S_Invisible);
			s->enable();
			s->setFloat(Shader::U_Visibility, 1.0 - RenderRectangle.transfer_data/32.0f);
			break;
		case _solid_transfer:
			//glColor4f(0,1,0,1);
      MatrixStack::Instance()->color4f(0,1,0,1);
			break;
		case _textured_transfer:
			if((RenderRectangle.flags&_SHADELESS_BIT) != 0) {
				if (renderStep == kDiffuse) {
					//glColor4f(1,1,1,1);
          MatrixStack::Instance()->color4f(1,1,1,1);
				} else {
					//glColor4f(0,0,0,1);
          MatrixStack::Instance()->color4f(0,0,0,1);
				}
				flare = -1;
			} else {
				canGlow = true;
			}
			break;
		default:
			//glColor4f(0,0,1,1);
      MatrixStack::Instance()->color4f(0,0,1,1);
	}

	if(s == NULL) {
		if(TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_BumpMap)) {
			s = Shader::get(renderStep == kGlow ? Shader::S_BumpBloom : Shader::S_Bump);
		} else {
			s = Shader::get(renderStep == kGlow ? Shader::S_WallBloom : Shader::S_Wall);
		}
		s->enable();
	}

	if (renderStep == kGlow) {
		s->setFloat(Shader::U_BloomScale, SkinPtr->BloomScale);
		s->setFloat(Shader::U_BloomShift, SkinPtr->BloomShift);
	}
	s->setFloat(Shader::U_Flare, flare);
	s->setFloat(Shader::U_SelfLuminosity, selfLuminosity);
	s->setFloat(Shader::U_Wobble, 0);
	s->setFloat(Shader::U_Depth, 0);
	s->setFloat(Shader::U_Glow, 0);

	glVertexPointer(3,GL_FLOAT,0,ModelPtr->Model.PosBase());
	glClientActiveTexture(GL_TEXTURE0);
	if (ModelPtr->Model.TxtrCoords.empty()) {
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	} else {
		glTexCoordPointer(2,GL_FLOAT,0,ModelPtr->Model.TCBase());
	}

  if( useShaderRenderer() ){
    glVertexAttribPointer(Shader::ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, 0, ModelPtr->Model.NormBase());
    glEnableVertexAttribArray(Shader::ATTRIB_NORMAL);
  } else {
    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(GL_FLOAT,0,ModelPtr->Model.NormBase());
  }
  
	glClientActiveTexture(GL_TEXTURE1);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glTexCoordPointer(4,GL_FLOAT,sizeof(vec4),ModelPtr->Model.TangentBase());

	if(ModelPtr->Use(CLUT,OGL_SkinManager::Normal)) {
		LoadModelSkin(SkinPtr->NormalImg, Collection, CLUT);
	}

	if(TEST_FLAG(Get_OGL_ConfigureData().Flags, OGL_Flag_BumpMap)) {
		glActiveTexture(GL_TEXTURE1);
		if(ModelPtr->Use(CLUT,OGL_SkinManager::Bump)) {
			LoadModelSkin(SkinPtr->OffsetImg, Collection, CLUT);
		}
		if (!SkinPtr->OffsetImg.IsPresent()) {
			FlatBumpTexture();
		}
		glActiveTexture(GL_TEXTURE0);
	}
  
  Shader* lastShader = lastEnabledShader();
  if (lastShader) {
    GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16];

    MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
    MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
    MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
    MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
    MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
    
    lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
    lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
    lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
    lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
    lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
    lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
  }

  glPushGroupMarkerEXT(0, "RenderModel");
	glDrawElements(GL_TRIANGLES,(GLsizei)ModelPtr->Model.NumVI(),GL_UNSIGNED_SHORT,ModelPtr->Model.VIBase());
  glPopGroupMarkerEXT();
  
	if (canGlow && SkinPtr->GlowImg.IsPresent()) {
		glEnable(GL_BLEND);
		setupBlendFunc(SkinPtr->GlowBlend);
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.001);

		s->enable();
		s->setFloat(Shader::U_Glow, SkinPtr->MinGlowIntensity);
		if (renderStep == kGlow) {
			s->setFloat(Shader::U_BloomScale, SkinPtr->GlowBloomScale);
			s->setFloat(Shader::U_BloomShift, SkinPtr->GlowBloomShift);
		}

		if(ModelPtr->Use(CLUT,OGL_SkinManager::Glowing)) {
			LoadModelSkin(SkinPtr->GlowImg, Collection, CLUT);
		}
    
    Shader* lastShader = lastEnabledShader();
    if (lastShader) {
      GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16];
      MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
      MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
      MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
      MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
      MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
      
      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
      lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
      lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
      lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
      lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
    }
    
    glPushGroupMarkerEXT(0, "RenderModel Glow");
		glDrawElements(GL_TRIANGLES,(GLsizei)ModelPtr->Model.NumVI(),GL_UNSIGNED_SHORT,ModelPtr->Model.VIBase());
    glPopGroupMarkerEXT();
	}

	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glClientActiveTexture(GL_TEXTURE0);
	if (ModelPtr->Model.TxtrCoords.empty()) {
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}

	// Restore the default render sidedness
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CW);
	Shader::disable();
	return true;
}

void RenderRasterize_Shader::render_node_object(render_object_data *object, bool other_side_of_media, RenderStep renderStep) {

    if (!object->clipping_windows)
        return;

	clipping_window_data *win;

	// To properly handle sprites in media, we render above and below
	// the media boundary in separate passes, just like the original
	// software renderer.
	short media_index = get_polygon_data(object->node->polygon_index)->media_index;
	media_data *media = (media_index != NONE) ? get_media_data(media_index) : NULL;
	if (media) {
		float h = media->height;
		GLfloat plane[] = { 0.0, 0.0, 1.0, -h };
    if (view->under_media_boundary ^ other_side_of_media) {
			plane[2] = -1.0;
			plane[3] = h;
		}
    if( useShaderRenderer() ){
      MatrixStack::Instance()->clipPlanef(5, plane);
      MatrixStack::Instance()->enablePlane(5);
    } else {
      glClipPlanef(GL_CLIP_PLANE5, plane);
      glEnable(GL_CLIP_PLANE5);
    }
	} else if (other_side_of_media) {
		// When there's no media present, we can skip the second pass.
		return;
	}

    for (win = object->clipping_windows; win; win = win->next_window)
    {
        clip_to_window(win);
        _render_node_object_helper(object, renderStep);
    }
  if( useShaderRenderer() ){
    MatrixStack::Instance()->disablePlane(5);
  } else {
    glDisable(GL_CLIP_PLANE5);
  }
}

void RenderRasterize_Shader::_render_node_object_helper(render_object_data *object, RenderStep renderStep) {

	rectangle_definition& rect = object->rectangle;
	const world_point3d& pos = rect.Position;
  
  GLint startingDepthFunction;
  glGetIntegerv(GL_DEPTH_FUNC, &startingDepthFunction);
  
	if(rect.ModelPtr) {
    //glPushMatrix();
    MatrixStack::Instance()->pushMatrix();
		//glTranslatef(pos.x, pos.y, pos.z);
    MatrixStack::Instance()->translatef(pos.x, pos.y, pos.z);
		//glRotatef((360.0/FULL_CIRCLE)*rect.Azimuth,0,0,1);
    MatrixStack::Instance()->rotatef((360.0/FULL_CIRCLE)*rect.Azimuth,0,0,1);
		GLfloat HorizScale = rect.Scale*rect.HorizScale;
		//glScalef(HorizScale,HorizScale,rect.Scale);
    MatrixStack::Instance()->scalef(HorizScale,HorizScale,rect.Scale);

		short descriptor = GET_DESCRIPTOR_COLLECTION(rect.ShapeDesc);
		short collection = GET_COLLECTION(descriptor);
		short clut = ModifyCLUT(rect.transfer_mode,GET_COLLECTION_CLUT(descriptor));

		RenderModel(rect, collection, clut, weaponFlare, selfLuminosity, renderStep);
		//glPopMatrix();
    MatrixStack::Instance()->popMatrix();
		return;
	}

	//glPushMatrix();
  MatrixStack::Instance()->pushMatrix();
	//glTranslatef(pos.x, pos.y, pos.z);
  MatrixStack::Instance()->translatef(pos.x, pos.y, pos.z);

	double yaw = view->yaw * 360.0 / float(NUMBER_OF_ANGLES);
	//glRotatef(yaw, 0.0, 0.0, 1.0);
  MatrixStack::Instance()->rotatef(yaw, 0.0, 0.0, 1.0);

	float offset = 0;
	if (OGL_ForceSpriteDepth()) {
		// look for parasitic objects based on y position,
		// and offset them to draw in proper depth order
		if(pos.y == objectY) {
			objectCount++;
			offset = objectCount * -1.0;
		} else {
			objectCount = 0;
			objectY = pos.y;
		}
	} else {
    //DCW I think I want sprites to write to the depth buffer, but not be tested against it themselves;
    //DCW; The depth function must be restored after this, or walls will stop drawing correctly in some cases.
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_ALWAYS);
    
		//glDisable(GL_DEPTH_TEST);
	}

	TextureManager TMgr = setupSpriteTexture(rect, OGL_Txtr_Inhabitant, offset, renderStep);
	if (TMgr.ShapeDesc == UNONE) {
    //glPopMatrix();
    MatrixStack::Instance()->popMatrix();
    glDepthFunc(startingDepthFunction);
    return; }

  //DCW set texture filtering to make the 2d sampler show anything but black.
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR );
  glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  
  
	float texCoords[2][2];

	if(rect.flip_vertical) {
		texCoords[0][1] = TMgr.U_Offset;
		texCoords[0][0] = TMgr.U_Scale+TMgr.U_Offset;
	} else {
		texCoords[0][0] = TMgr.U_Offset;
		texCoords[0][1] = TMgr.U_Scale+TMgr.U_Offset;
	}

	if(rect.flip_horizontal) {
		texCoords[1][1] = TMgr.V_Offset;
		texCoords[1][0] = TMgr.V_Scale+TMgr.V_Offset;
	} else {
		texCoords[1][0] = TMgr.V_Offset;
		texCoords[1][1] = TMgr.V_Scale+TMgr.V_Offset;
	}

	if(TMgr.IsBlended() || TMgr.TransferMode == _tinted_transfer) {
		glEnable(GL_BLEND);
		setupBlendFunc(TMgr.NormalBlend());
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.001);
	} else {
		glDisable(GL_BLEND);
		glEnable(GL_ALPHA_TEST);
		glAlphaFunc(GL_GREATER, 0.5);
	}
  
    //DCW maybe we always want blending in the shader renderer?
  if( useShaderRenderer() ) {
    glEnable(GL_BLEND);
  }
  
  // DJB OpenGL Convert from quad
  //DCW I don't think we need this
  /*GLfloat t[8] = {
    texCoords[0][0], texCoords[1][0],
    texCoords[0][0], texCoords[1][1],
    texCoords[0][1], texCoords[1][1],
    texCoords[0][1], texCoords[1][0],
  };
  GLfloat v[12] = {
    0, rect.WorldLeft * rect.HorizScale * rect.Scale, rect.WorldTop * rect.Scale,
    0, rect.WorldRight * rect.HorizScale * rect.Scale, rect.WorldTop * rect.Scale,
    0, rect.WorldRight * rect.HorizScale * rect.Scale, rect.WorldBottom * rect.Scale,
    0, rect.WorldLeft * rect.HorizScale * rect.Scale, rect.WorldBottom * rect.Scale,
  };*/
  
  //DCW restoring this:
  GLfloat vertex_array[12] = {
    0,
    rect.WorldLeft * rect.HorizScale * rect.Scale,
    rect.WorldTop * rect.Scale,
    0,
    rect.WorldRight * rect.HorizScale * rect.Scale,
    rect.WorldTop * rect.Scale,
    0,
    rect.WorldRight * rect.HorizScale * rect.Scale,
    rect.WorldBottom * rect.Scale,
    0,
    rect.WorldLeft * rect.HorizScale * rect.Scale,
    rect.WorldBottom * rect.Scale
  };
  GLfloat texcoord_array[8] = {
    texCoords[0][0],
    texCoords[1][0],
    texCoords[0][0],
    texCoords[1][1],
    texCoords[0][1],
    texCoords[1][1],
    texCoords[0][1],
    texCoords[1][0]
  };
  
  
  if( useShaderRenderer() ){
    glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texcoord_array);
    glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
    
    glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vertex_array);
    glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
  } else {
    glVertexPointer(2, GL_FLOAT, 0, texcoord_array);
    glEnableClientState(GL_VERTEX_ARRAY);
    glTexCoordPointer(3, GL_FLOAT, 0, vertex_array);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  }
  
  Shader* lastShader = lastEnabledShader();
  if (lastShader) {
    GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16];
    MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
    MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
    MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
    MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
    MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
    
    lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
    lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
    lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
    lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
    lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
    lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
    
    GLfloat plane0[4], plane1[4], plane5[4], media6[4];
    MatrixStack::Instance()->getPlanev(0, plane0);
    MatrixStack::Instance()->getPlanev(1, plane1);
    MatrixStack::Instance()->getPlanev(5, plane5);
    MatrixStack::Instance()->getPlanev(6, media6);
    lastShader->setVec4(Shader::U_ClipPlane0, plane0);
    lastShader->setVec4(Shader::U_ClipPlane1, plane1);
    lastShader->setVec4(Shader::U_ClipPlane5, plane5);
    lastShader->setVec4(Shader::U_MediaPlane6, media6);
  }
  
  glPushGroupMarkerEXT(0, "render_node_object_helper");
  glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
  glPopGroupMarkerEXT();
  /*
	

	glVertexPointer(3, GL_FLOAT, 0, vertex_array);
	glTexCoordPointer(2, GL_FLOAT, 0, texcoord_array);

	glDrawArrays(GL_QUADS, 0, 4);*/

	if (setupGlow(view, TMgr, 0, 1, weaponFlare, selfLuminosity, offset, renderStep)) {
    //DCW set texture filtering to make the 2d sampler show anything but black.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    
    
    // DJB OpenGL Convert from quad
    //DCW I think we don't want this.
    /*
    GLfloat t[8] = {
      texCoords[0][0], texCoords[1][0],
      texCoords[0][0], texCoords[1][1],
      texCoords[0][1], texCoords[1][1],
      texCoords[0][1], texCoords[1][0],
    };
    GLfloat v[12] = {
      0, rect.WorldLeft * rect.HorizScale * rect.Scale, rect.WorldTop * rect.Scale,
      0, rect.WorldRight * rect.HorizScale * rect.Scale, rect.WorldTop * rect.Scale,
      0, rect.WorldRight * rect.HorizScale * rect.Scale, rect.WorldBottom * rect.Scale,
      0, rect.WorldLeft * rect.HorizScale * rect.Scale, rect.WorldBottom * rect.Scale,
    };*/
    
    if( useShaderRenderer() ){
      glVertexAttribPointer(Shader::ATTRIB_TEXCOORDS, 2, GL_FLOAT, 0, 0, texcoord_array);
      glEnableVertexAttribArray(Shader::ATTRIB_TEXCOORDS);
      
      glVertexAttribPointer(Shader::ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vertex_array);
      glEnableVertexAttribArray(Shader::ATTRIB_VERTEX);
    } else {
      glVertexPointer(2, GL_FLOAT, 0, vertex_array);
      glEnableClientState(GL_VERTEX_ARRAY);
      glTexCoordPointer(3, GL_FLOAT, 0, texcoord_array);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    Shader* lastShader = lastEnabledShader();
    if (lastShader) {
      GLfloat modelMatrix[16], projectionMatrix[16], modelProjection[16], modelMatrixInverse[16], textureMatrix[16];
      MatrixStack::Instance()->getFloatv(MS_MODELVIEW, modelMatrix);
      MatrixStack::Instance()->getFloatv(MS_PROJECTION, projectionMatrix);
      MatrixStack::Instance()->getFloatvInverse(MS_MODELVIEW, modelMatrixInverse);
      MatrixStack::Instance()->getFloatvModelviewProjection(modelProjection);
      MatrixStack::Instance()->getFloatv(MS_TEXTURE, textureMatrix);
      
      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrix, modelMatrix);
      lastShader->setMatrix4(Shader::U_MS_ModelViewProjectionMatrix, modelProjection);
      lastShader->setMatrix4(Shader::U_MS_ModelViewMatrixInverse, modelMatrixInverse);
      lastShader->setMatrix4(Shader::U_MS_TextureMatrix, textureMatrix);
      lastShader->setVec4(Shader::U_MS_Color, MatrixStack::Instance()->color());
      lastShader->setVec4(Shader::U_MS_FogColor, MatrixStack::Instance()->fog());
      
      GLfloat plane0[4], plane1[4], plane5[4];
      MatrixStack::Instance()->getPlanev(0, plane0);
      MatrixStack::Instance()->getPlanev(1, plane1);
      MatrixStack::Instance()->getPlanev(5, plane5);
      lastShader->setVec4(Shader::U_ClipPlane0, plane0);
      lastShader->setVec4(Shader::U_ClipPlane1, plane1);
      lastShader->setVec4(Shader::U_ClipPlane5, plane5);
    }
    
    glPushGroupMarkerEXT(0, "render_node_object_helper glow");
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    glPopGroupMarkerEXT();
		//glDrawArrays(GL_QUADS, 0, 4);
	}

	glEnable(GL_DEPTH_TEST);
  glDepthFunc(startingDepthFunction);
  
	//glPopMatrix();
  MatrixStack::Instance()->popMatrix();
	Shader::disable();
	TMgr.RestoreTextureMatrix();
}
