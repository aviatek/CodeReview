package de.softgames.iso.display
{
    import de.softgames.iso.IsoScene;
    import de.softgames.iso.events.IsoViewportEvent;
    import de.softgames.iso.geom.IsoPoint;
    
    import flash.display.Sprite;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    /**
     * Disptached when item has been added to viewport.
     * 
     * @eventType de.softgames.iso.events.IsoViewportEvent.ITEM_ADDED
     */
    [Event(type="de.softgames.iso.events.IsoViewportEvent", name="itemAdded")]
    
    /**
     * Disptached when item has been removed from viewport.
     * 
     * @eventType de.softgames.iso.events.IsoViewportEvent.ITEM_REMOVED
     */
    [Event(type="de.softgames.iso.events.IsoViewportEvent", name="itemRemoved")]
    
    /**
     * Isometric scene viewport.
     */
    public class IsoViewport extends Sprite
    {
        private var _isoItemsContainer     : Sprite;
        private var _floorContainer        : Sprite;
        private var _renderBounds          : Rectangle;
        private var _itemsContainerOffset  : Point;
        private var _container             : Sprite;
        private var _zoom                  : Number = 1;
        private var _scene                 : IsoScene;
        
        /**
         * Constructor.
         * 
         * @param renderBounds Render bounds. Everything which is outside those bounds will be removed from scene to save CPU.
         */ 
        public function IsoViewport(renderBounds : Rectangle)
        {
            super();
            
            _renderBounds = renderBounds;
            _itemsContainerOffset = new Point();
            
            _container   = new Sprite();
            _container.x = Math.round(width / 2);
            _container.y = Math.round(height / 2);
            addChild(_container);
            
            _floorContainer = new Sprite();
            _container.addChild(_floorContainer);
            
            _isoItemsContainer = new Sprite();
            _container.addChild(_isoItemsContainer);
        }
        
        /**
         * Connects this viewport with scene model.
         */
        public function setScene(scene : IsoScene) : void
        {
            _scene = scene;

            var p : IsoPoint = new IsoPoint();
            p.set(scene.numTilesX * scene.tileSize, scene.numTilesY * scene.tileSize);
            
            _isoItemsContainer.x    = 0;
            _isoItemsContainer.y    = -Math.round(p.cartesianY / 2);
            _floorContainer.x       = _isoItemsContainer.x;
            _floorContainer.y       = _isoItemsContainer.y;
            _itemsContainerOffset.x = _isoItemsContainer.x;
            _itemsContainerOffset.y = -_isoItemsContainer.y;
        }
        
        /**
         * Addds item to viewport display list.
         * 
         * @param item Item to add.
         */
        public function addIsoItem(item : IsoDisplayObject) : void
        {
            _isoItemsContainer.addChild(item);
            
            var event : IsoViewportEvent = new IsoViewportEvent(IsoViewportEvent.ITEM_ADDED);
            event.isoItem = item;
            dispatchEvent(event);
        }
        
        /**
         * Removes item from viewport display list.
         */
        public function removeIsoItem(item : IsoDisplayObject) : void
        {
            _isoItemsContainer.removeChild(item);
            
            var event : IsoViewportEvent = new IsoViewportEvent(IsoViewportEvent.ITEM_REMOVED);
            event.isoItem = item;
            dispatchEvent(event);
        }
        
        /**
         * Checks if item is contained by this viewport instance.
         */
        public function containsIsoItem(item : IsoDisplayObject) : Boolean
        {
            return _isoItemsContainer.contains(item);
        }

        public function get isoItemsContainer() : Sprite
        {
            return _isoItemsContainer;
        }
        
        /**
         * Viewport render bounds.
         */
        public function get renderBounds() : Rectangle
        {
            return _renderBounds;
        }

        public function set renderBounds(value : Rectangle) : void
        {
            _renderBounds = value;
        }

        override public function get width() : Number
        {
            return renderBounds.width;
        }
        
        override public function get height() : Number
        {
            return renderBounds.height;
        }
        
        /**
         * Container for a specific part of the scene - floor.
         */
        public function get floorContainer() : Sprite
        {
            return _floorContainer;
        }
        
        /**
         * Viewport zoom - <code>1</code> means <code>100%</code>, <code>0.5</code> means <code>50%</code> etc.
         */
        public function get zoom() : Number
        {
            return _zoom;
        }

        public function set zoom(value : Number) : void
        {
            _zoom = value;
            _container.scaleX = zoom;
            _container.scaleY = zoom;
        }

        public function get scene() : IsoScene
        {
            return _scene;
        }

        public function get itemsContainerOffset() : Point
        {
            return _itemsContainerOffset;
        }
    }
}