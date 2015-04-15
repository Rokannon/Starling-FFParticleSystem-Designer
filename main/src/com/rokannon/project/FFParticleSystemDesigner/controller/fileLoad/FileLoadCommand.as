package com.rokannon.project.FFParticleSystemDesigner.controller.fileLoad
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.Event;
    import flash.events.IOErrorEvent;

    public class FileLoadCommand extends CommandBase
    {
        private var _data:FileLoadCommandData;

        public function FileLoadCommand(data:FileLoadCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _data.fileToLoad.addEventListener(Event.COMPLETE, onLoadComplete);
            _data.fileToLoad.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            _data.fileToLoad.load();
        }

        private function onLoadError(event:IOErrorEvent):void
        {
            _data.fileToLoad.removeEventListener(Event.COMPLETE, onLoadComplete);
            _data.fileToLoad.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            onFailed();
        }

        private function onLoadComplete(event:Event):void
        {
            _data.fileToLoad.removeEventListener(Event.COMPLETE, onLoadComplete);
            _data.fileToLoad.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            _data.fileModel.fileContent = _data.fileToLoad.data;
            onComplete();
        }
    }
}