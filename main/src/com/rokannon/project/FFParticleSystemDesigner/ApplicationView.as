package com.rokannon.project.FFParticleSystemDesigner
{
    import feathers.themes.MetalWorksDesktopTheme;

    import starling.display.Sprite;
    import starling.events.Event;

    public class ApplicationView extends Sprite
    {
        public const particleSystemLayer:Sprite = new Sprite();
        public const guiLayer:Sprite = new Sprite();

        public function ApplicationView()
        {
            super();
            if (stage != null)
                onAddedToStage();
            else
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        private function onAddedToStage(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            new MetalWorksDesktopTheme();
            addChild(particleSystemLayer);
            addChild(guiLayer);
        }
    }
}