package com.rokannon.project.FFParticleSystemDesigner.controller.fileCopy
{
    import com.rokannon.core.command.CommandBase;

    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    public class FileCopyCommand extends CommandBase
    {
        private var _data:FileCopyCommandData;

        public function FileCopyCommand(data:FileCopyCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            var newFileName:String;
            if (_data.newFileName == null)
                newFileName = _data.fileToCopy.name;
            else
                newFileName = _data.newFileName;
            var newFile:File = _data.directoryToCopyTo.resolvePath(newFileName);
            _data.fileToCopy.addEventListener(Event.COMPLETE, onCopyComplete);
            _data.fileToCopy.addEventListener(IOErrorEvent.IO_ERROR, onCopyError);
            _data.fileToCopy.copyToAsync(newFile, _data.overwrite);
        }

        private function onCopyError(event:IOErrorEvent):void
        {
            _data.fileToCopy.removeEventListener(Event.COMPLETE, onCopyComplete);
            _data.fileToCopy.removeEventListener(IOErrorEvent.IO_ERROR, onCopyError);
            onFailed();
        }

        private function onCopyComplete(event:Event):void
        {
            _data.fileToCopy.removeEventListener(Event.COMPLETE, onCopyComplete);
            _data.fileToCopy.removeEventListener(IOErrorEvent.IO_ERROR, onCopyError);
            onComplete();
        }
    }
}