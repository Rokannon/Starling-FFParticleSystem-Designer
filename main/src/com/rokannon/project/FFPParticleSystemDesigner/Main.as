package com.rokannon.project.FFPParticleSystemDesigner
{
    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.text.TextField;

    public class Main extends Sprite
    {
        public function Main()
        {
            if (stage == null)
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            else
                onAddedToStage();
        }

        function onAddedToStage(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);

            stage.scaleMode = StageScaleMode.NO_SCALE;

            var textField:TextField = new TextField();
            textField.text = "Hello, World";
            addChild(textField);
        }
    }
}