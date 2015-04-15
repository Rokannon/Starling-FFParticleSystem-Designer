package com.rokannon.project.FFParticleSystemDesigner.controller.createBitmap
{
    import com.rokannon.core.command.CommandBase;

    import flash.display.Bitmap;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.events.IOErrorEvent;

    public class CreateBitmapCommand extends CommandBase
    {
        private const _loader:Loader = new Loader();
        private var _data:CreateBitmapCommandData;

        public function CreateBitmapCommand(data:CreateBitmapCommandData)
        {
            super();
            _data = data;
        }

        override protected function onStart():void
        {
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
            _loader.loadBytes(_data.fileModel.fileContent);
        }

        private function onLoaderComplete(event:Event):void
        {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
            _data.fileModel.fileBitmap = event.target.content as Bitmap;
            onComplete();
        }

        private function onLoaderError(event:IOErrorEvent):void
        {
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
            _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
            _data.fileModel.fileBitmap = null;
            onFailed();
        }
    }
}