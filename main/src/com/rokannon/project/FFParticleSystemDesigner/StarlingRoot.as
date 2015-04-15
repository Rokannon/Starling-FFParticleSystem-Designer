package com.rokannon.project.FFParticleSystemDesigner
{
    import com.rokannon.project.FFParticleSystemDesigner.controller.ApplicationController;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;

    import de.flintfabrik.starling.display.FFParticleSystem;

    import feathers.themes.MetalWorksDesktopTheme;

    import starling.display.Sprite;

    public class StarlingRoot extends Sprite
    {
        public function StarlingRoot()
        {
            super();
        }

        public function startApplication(appModel:ApplicationModel, appController:ApplicationController):void
        {
            FFParticleSystem.init(4096, false, 4096, 16);

            appController.loadConfig();
            appController.loadParticleSystem();

            new MetalWorksDesktopTheme();
        }
    }
}