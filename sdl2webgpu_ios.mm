#include "sdl2webgpu_ios.h"
#include <webgpu/webgpu.h>

#include <SDL2/SDL.h>
#include <SDL2/SDL_syswm.h>

#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


WGPUSurface SDL_GetWGPUSurface(WGPUInstance instance, SDL_Window* window) {
    SDL_SysWMinfo windowWMInfo;
    SDL_VERSION(&windowWMInfo.version);
    SDL_GetWindowWMInfo(window, &windowWMInfo);
    
    UIWindow* ui_window = windowWMInfo.info.uikit.window;
    UIView* ui_view = ui_window.rootViewController.view;
    CAMetalLayer* metal_layer = [CAMetalLayer new];
    metal_layer.opaque = true;
    metal_layer.frame = ui_view.frame;
    metal_layer.drawableSize = ui_view.frame.size;
    
    [ui_view.layer addSublayer: metal_layer];

    WGPUSurfaceDescriptorFromMetalLayer metalLayerDesc = {
        .chain = {
            .next = NULL,
            .sType = WGPUSType_SurfaceDescriptorFromMetalLayer,
        },
        .layer = (__bridge void*)metal_layer,
    };

    WGPUSurfaceDescriptor surfaceDesc = {
        .label = NULL,
        .nextInChain = (const WGPUChainedStruct*)&metalLayerDesc,
    };

    return wgpuInstanceCreateSurface(instance, &surfaceDesc);
}

