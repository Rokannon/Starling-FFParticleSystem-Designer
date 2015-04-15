package com.rokannon.project.FFParticleSystemDesigner
{
    import com.rokannon.project.FFParticleSystemDesigner.controller.ApplicationController;
    import com.rokannon.project.FFParticleSystemDesigner.controller.startStarling.StartStarlingCommand;
    import com.rokannon.project.FFParticleSystemDesigner.controller.startStarling.StartStarlingCommandData;
    import com.rokannon.project.FFParticleSystemDesigner.model.ApplicationModel;

    import flash.display.Sprite;
    import flash.display.StageScaleMode;
    import flash.events.Event;

    [SWF(frameRate=60, width=800, height=600)]
    public class Main extends Sprite
    {
        private const _appModel:ApplicationModel = new ApplicationModel();
        private const _appController:ApplicationController = new ApplicationController();

        public function Main()
        {
            if (stage == null)
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            else
                onAddedToStage();
        }

        private function onAddedToStage(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            stage.scaleMode = StageScaleMode.NO_SCALE;

            _appController.connect(_appModel);

            var startStarlingCommandData:StartStarlingCommandData = new StartStarlingCommandData();
            startStarlingCommandData.appModel = _appModel;
            startStarlingCommandData.appController = _appController;
            startStarlingCommandData.nativeStage = stage;
            startStarlingCommandData.showStats = true;
            _appModel.commandExecutor.pushCommand(new StartStarlingCommand(startStarlingCommandData));
        }
    }
}