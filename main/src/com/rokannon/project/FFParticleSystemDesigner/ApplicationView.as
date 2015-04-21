package com.rokannon.project.FFParticleSystemDesigner
{
    import com.rokannon.project.FFParticleSystemDesigner.controller.ApplicationController;

    import feathers.controls.Button;
    import feathers.controls.LayoutGroup;
    import feathers.layout.AnchorLayout;
    import feathers.layout.AnchorLayoutData;
    import feathers.themes.MetalWorksDesktopTheme;

    import starling.display.Sprite;
    import starling.events.Event;

    public class ApplicationView extends Sprite
    {
        public const particleSystemLayer:Sprite = new Sprite();
        public const guiLayer:Sprite = new Sprite();

        private var _appController:ApplicationController;
        private var _reloadButton:Button;
        private var _openButton:Button;
        private var _browseButton:Button;
        private var _resetButton:Button;

        public function ApplicationView()
        {
            super();
            if (stage != null)
                onAddedToStage();
            else
                addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }

        public function connect(appController:ApplicationController):void
        {
            _appController = appController;
        }

        public function lockButtons():void
        {
            _reloadButton.isEnabled = false;
            _resetButton.isEnabled = false;
        }

        public function unlockButtons():void
        {
            _reloadButton.isEnabled = true;
            _resetButton.isEnabled = true;
        }

        private function onAddedToStage(event:Event = null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            new MetalWorksDesktopTheme();
            addChild(particleSystemLayer);
            addChild(guiLayer);

            var layoutGroup:LayoutGroup = new LayoutGroup();
            addChild(layoutGroup);
            layoutGroup.layout = new AnchorLayout();
            layoutGroup.autoSizeMode = LayoutGroup.AUTO_SIZE_MODE_STAGE;

            _reloadButton = new Button();
            _reloadButton.label = "Reload";
            _reloadButton.layoutData = new AnchorLayoutData(NaN, 10, 10);
            layoutGroup.addChild(_reloadButton);
            _reloadButton.addEventListener(Event.TRIGGERED, onReloadButtonTriggered);

            var anchorLayoutData:AnchorLayoutData;

            _openButton = new Button();
            _openButton.label = "Open";
            anchorLayoutData = new AnchorLayoutData(NaN, 10, 10);
            anchorLayoutData.bottomAnchorDisplayObject = _reloadButton;
            _openButton.layoutData = anchorLayoutData;
            layoutGroup.addChild(_openButton);
            _openButton.addEventListener(Event.TRIGGERED, onOpenButtonTriggered);

            _browseButton = new Button();
            _browseButton.label = "Browse";
            anchorLayoutData = new AnchorLayoutData(NaN, 10, 10);
            anchorLayoutData.bottomAnchorDisplayObject = _openButton;
            _browseButton.layoutData = anchorLayoutData;
            layoutGroup.addChild(_browseButton);
            _browseButton.addEventListener(Event.TRIGGERED, onBrowseButtonTriggered);

            _resetButton = new Button();
            _resetButton.label = "Reset";
            anchorLayoutData = new AnchorLayoutData(NaN, 10, 10);
            anchorLayoutData.bottomAnchorDisplayObject = _browseButton;
            _resetButton.layoutData = anchorLayoutData;
            layoutGroup.addChild(_resetButton);
            _resetButton.addEventListener(Event.TRIGGERED, onResetButtonTriggered);
        }

        private function onReloadButtonTriggered(event:Event):void
        {
            _appController.particleSystemController.loadParticleSystem();
        }

        private function onOpenButtonTriggered(event:Event):void
        {
            _appController.particleSystemController.openParticleSystemLocation();
        }

        private function onBrowseButtonTriggered(event:Event):void
        {
            _appController.particleSystemController.browseParticleSystem();
        }

        private function onResetButtonTriggered(event:Event):void
        {
            _appController.particleSystemController.resetParticleSystem();
        }
    }
}