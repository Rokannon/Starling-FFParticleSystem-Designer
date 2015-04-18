package com.rokannon.project.FFParticleSystemDesigner.controller.directoryBrowse
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.Event;
    import flash.events.IOErrorEvent;

    public class DirectoryBrowseCommand extends CommandBase
    {
        public var browseCanceled:Boolean = false;

        private var _data:DirectoryBrowseCommandData;

        public function DirectoryBrowseCommand(data:DirectoryBrowseCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _data.directoryToBrowse.addEventListener(Event.SELECT, onBrowseComplete);
            _data.directoryToBrowse.addEventListener(IOErrorEvent.IO_ERROR, onBrowseError);
            _data.directoryToBrowse.addEventListener(Event.CANCEL, onBrowseError);
            _data.directoryToBrowse.browseForDirectory(_data.browseTitle);
        }

        private function onBrowseError(event:IOErrorEvent):void
        {
            _data.directoryToBrowse.removeEventListener(Event.SELECT, onBrowseComplete);
            _data.directoryToBrowse.removeEventListener(IOErrorEvent.IO_ERROR, onBrowseError);
            _data.directoryToBrowse.removeEventListener(Event.CANCEL, onBrowseError);
            browseCanceled = event.type == Event.CANCEL;
            onFailed();
        }

        private function onBrowseComplete(event:Event):void
        {
            _data.directoryToBrowse.removeEventListener(Event.SELECT, onBrowseComplete);
            _data.directoryToBrowse.removeEventListener(IOErrorEvent.IO_ERROR, onBrowseError);
            _data.directoryToBrowse.removeEventListener(Event.CANCEL, onBrowseError);
            onComplete();
        }
    }
}