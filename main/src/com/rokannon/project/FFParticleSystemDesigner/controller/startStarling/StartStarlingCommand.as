package com.rokannon.project.FFParticleSystemDesigner.controller.startStarling
{
    import com.rokannon.core.command.CommandBase;
    import com.rokannon.project.FFParticleSystemDesigner.ApplicationView;

    import starling.core.Starling;
    import starling.events.Event;

    public class StartStarlingCommand extends CommandBase
    {
        private var _data:StartStarlingCommandData;

        public function StartStarlingCommand(data:StartStarlingCommandData)
        {
            _data = data;
        }

        override protected function onStart():void
        {
            _data.appModel.starlingInstance = new Starling(ApplicationView, _data.nativeStage);
            _data.appModel.starlingInstance.addEventListener(Event.ROOT_CREATED, onRootCreated);
            _data.appModel.starlingInstance.start();
        }

        private function onRootCreated(event:Event):void
        {
            _data.appModel.starlingInstance.removeEventListener(Event.ROOT_CREATED, onRootCreated);
            _data.appModel.starlingInstance.showStats = _data.showStats;
            onComplete();
        }
    }
}