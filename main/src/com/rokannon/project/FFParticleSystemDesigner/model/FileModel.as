package com.rokannon.project.FFParticleSystemDesigner.model
{
    import flash.display.Bitmap;
    import flash.filesystem.File;
    import flash.utils.ByteArray;

    public class FileModel
    {
        public const directoryListing:Vector.<File> = new <File>[];
        public var fileContent:ByteArray;
        public var fileBitmap:Bitmap;
    }
}