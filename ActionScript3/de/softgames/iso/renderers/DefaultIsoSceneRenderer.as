package de.softgames.iso.renderers
{
    import de.softgames.iso.display.CharacterIsoItem;
    import de.softgames.iso.display.IsoDisplayObject;
    import de.softgames.iso.events.IsoEvent;
    import de.softgames.utils.MathUtil;
    
    import flash.utils.Dictionary;
    
    public class DefaultIsoSceneRenderer extends IsoSceneRenderer
    {
        private var _depth             : uint;
        private var _displayListDepth  : uint;
        private var _needSorting       : Boolean;
        private var _effort            : uint;
        private var _dynamicItems      : Vector.<DefaultIsoSceneRendererItem>;
        private var _staticItems       : Vector.<DefaultIsoSceneRendererItem>;
        private var _dictionary        : Dictionary;
        
        public function DefaultIsoSceneRenderer()
        {
            super();
            
            _dictionary   = new Dictionary();
            _dynamicItems = new Vector.<DefaultIsoSceneRendererItem>();
            _staticItems  = new Vector.<DefaultIsoSceneRendererItem>();
        }
        
        override protected function _sceneStepperStepAction() : void
        {
            sortDynamicItems();
        }
        
        private function _sort(dynamic : Boolean = false) : void
        {
            /*
             * Creating list containg items that should be sorted. If this is dynamic sort, 
             * then there will be only dynamic items in this list.
             */
            var listA : Vector.<DefaultIsoSceneRendererItem>;
            listA = dynamic ? _dynamicItems : _staticItems;
            
            /*
            * Creating list containg all static items and also dynamic items (if dynamic sort) in the of the list.
            * We will sort listA list items against this list.
            */ 
            var listB : Vector.<DefaultIsoSceneRendererItem>;
            listB = dynamic ? _staticItems.slice().concat(_dynamicItems) : _staticItems;
            
            /*
            * Helper vars:
            */ 
            var itemA : DefaultIsoSceneRendererItem;
            var itemB : DefaultIsoSceneRendererItem;
            var n     : uint = listA.length;
            var m     : uint = listB.length;
            var i     : uint;
            var j     : uint;
            
            _effort = 0;
            
            // Resetting all dynamicsBehind lists for all items
            if(dynamic)
            {
                for(i=0; i < m; i++)
                {
                    itemB = listB[i];
                    itemB.dynamicsBehind = itemB.behind.slice();
                    itemB.visited = false;
                    itemB.isoItem.zoom = scene.zoom;
                    itemB.isoItem.checkIfItemIsInViewportBounds();
                    _effort++;
                }
            }
            
            // Sorting
            for(i=0; i < n; i++)
            {
                itemA = listA[i];
                itemA.visited = false; // this is needed if this is not dynamic sort
                
                // Clear behind list if not a dynamic sort
                if(!dynamic)
                    itemA.behind.splice(0, itemA.behind.length);
                
                if(!itemA.isoItem.stage && dynamic)
                    continue;
                
                for(j=0; j < m; j++)
                {
                    _effort++;
                    
                    // Static or dynamic item:
                    itemB = listB[j];
                    
                    if(itemA == itemB || (dynamic && !itemB.isoItem.stage))
                        continue;
                    
                    /*
                    * Check if itemA is behind itemB or opposite only if those items 
                    * on screen render area intersects:
                    */ 
                    if(itemA.isoItem.getRenderBounds().intersects(itemB.isoItem.getRenderBounds()))
                    {
                        if(dynamic)
                        {
                            if(_isBehind(itemA.isoItem, itemB.isoItem)) // itemA is behind itemB
                            {
                                itemB.dynamicsBehind.push(itemA);
                            }
                            else // itemB is behind itemA
                            {
                                itemA.dynamicsBehind.push(itemB);
                            }
                        }
                        else
                        {
                            if(_isBehind(itemB.isoItem, itemA.isoItem)) // itemB is behind itemA
                                itemA.behind.push(itemB);
                        }
                    }
                }
            }
            
            _depth = 0;
            _displayListDepth = 0;
            
            // Placing items on display list:
            for each(var item : DefaultIsoSceneRendererItem in listB)
            {
                if(!item.visited) _placeItem(item, dynamic);
            }
            
            //trace("effort: " + _effort + " for sorting: " + (m));
        }
        
        /**
         * Forces resorting all items on stage (scene).
         */
        public function sortAll() : void
        {    
            _sort(false);
            sortDynamicItems();
        }
        
        /**
         * Sorts all dynamic items on scene against static items. Dynamic items are for example 
         * avatars and static items are buildings etc.
         * 
         * You need to be sure that all static items are properly sorted by sortAll() method before calling this method.
         */ 
        public function sortDynamicItems() : void
        {
            _sort(true);
        }
        
        /**
         * Recursive method for placing items on display list in sorted order.
         * 
         * @param item Item do place.
         * @param isDynamic If this is dynamic or static sort.
         */ 
        private function _placeItem(item : DefaultIsoSceneRendererItem, isDynamic : Boolean = false) : void
        {
            item.visited = true;
            
            /*
             * If this is "dynamic against static" items sort, then we need to iterate through
             * dynamicsBehind list which includes presorted static items and dynamic items that has just been sorted:
             */ 
            var list : Vector.<DefaultIsoSceneRendererItem> = isDynamic ? item.dynamicsBehind : item.behind;
            
            for each(var child : DefaultIsoSceneRendererItem in list)
            {
                if(!child.visited) _placeItem(child, isDynamic);
            }
            
            item.depth = _depth;
            item.isoItem.depth = item.depth;
            
            if(item.isoItem.stage)
            {
                scene.viewport.isoItemsContainer.setChildIndex(item.isoItem, _displayListDepth);
                _displayListDepth++;
            }
            
            _depth++;
            _effort++;
        }
        
        /**
         * Checks if itemA is behind itemB. It is needed in depth sorting.
         * 
         * @return <code>true</code> if itemA is behind itemB; otherwise <code>false</code>.
         */ 
        private function _isBehind(itemA : IsoDisplayObject, itemB : IsoDisplayObject) : Boolean
        {
            if(itemA == itemB)
                return false;
            
            if(itemA is CharacterIsoItem && itemB is CharacterIsoItem)
                return IsoDisplayObject.getDepth(itemA.x, itemA.y, itemA.z) < IsoDisplayObject.getDepth(itemB.x, itemB.y, itemB.z);
            else
                return itemA.x + itemA.width <= itemB.x || itemA.y + itemA.length <= itemB.y || itemA.z + itemA.height <= itemB.z;
            
            return false;
        }
        
        /**
         * Checks if itemA render area intersects with itemB render area.  
         * This method is quite complex because it divides iso render polygon into 4 triangles and computes interesction between 
         * corners and those triangles so it's not well optimized. If not needed it's better to use rectangles intersection.
         * 
         * @param itemA First item.
         * @param itemB Second item.
         * @return <code>true</code> if render areas do intersect; otherwise <code>false</code>.
         */ 
        private function _isOverlaped(itemA : IsoDisplayObject, itemB : IsoDisplayObject) : Boolean
        {
            var t1 : Array = [  itemB.viewportTopX, itemB.viewportTopY, itemB.viewportTopRightX, 
                                itemB.viewportTopRightY, itemB.viewportTopLeftX, itemB.viewportTopLeftY];
            var t2 : Array = [  itemB.viewportTopLeftX, itemB.viewportTopLeftY, itemB.viewportTopRightX, 
                                itemB.viewportTopRightY, itemB.viewportBottomX, itemB.viewportBottomY];
            var t3 : Array = [  itemB.viewportTopRightX, itemB.viewportTopRightY, itemB.viewportBottomRightX, 
                                itemB.viewportBottomRightY, itemB.viewportBottomX, itemB.viewportBottomY];
            var t4 : Array = [  itemB.viewportTopLeftX, itemB.viewportTopLeftY, itemB.viewportBottomX, 
                                itemB.viewportBottomY, itemB.viewportBottomLeftX, itemB.viewportBottomLeftY];
            
            var triangles : Array = [t1, t2, t3, t4];
            var i : uint;
            var j : uint;
                
            var points : Array = [  itemA.viewportTopLeftX, itemA.viewportTopLeftY, 
                                    itemA.viewportTopX, itemA.viewportTopY, 
                                    itemA.viewportTopRightX, itemA.viewportTopRightY, 
                                    itemA.viewportBottomLeftX, itemA.viewportBottomLeftY, 
                                    itemA.viewportBottomX, itemA.viewportBottomY, 
                                    itemA.viewportBottomRightX, itemA.viewportBottomRightY];
            
            for(i=0; i < points.length; i+=2)
            {
                for(j=0; j < triangles.length; j++)
                {
                    var t : Array = triangles[j];
                    _effort++;
                    if(MathUtil.pointIntersectsTriangle(points[i], points[i+1], triangles[j][0], triangles[j][1], 
                                            triangles[j][2], triangles[j][3], triangles[j][4], triangles[j][5]))
                    {
                        return true;
                    }
                }
            }
            
            return false;
        }
        
        override protected function _sceneItemAddedHandler(event : IsoEvent) : void
        {
            super._sceneItemAddedHandler(event);
            
            var item : DefaultIsoSceneRendererItem = new DefaultIsoSceneRendererItem();
            item.isoItem = event.isoItem;
            _children.push(item);
            
            if(item.isoItem.isDynamic)
            {
                item.isDynamic = true;
                _dynamicItems.push(item);
            }
            else
            {
                item.isDynamic = false;
                _staticItems.push(item);
            }
            
            _dictionary[item.isoItem] = item;
        }
        
        override protected function _sceneItemRemovedHandler(event : IsoEvent) : void
        {
            super._sceneItemRemovedHandler(event);
            
            var item  : DefaultIsoSceneRendererItem = _dictionary[event.isoItem];
            var index : int = _children.indexOf(item);
            
            if(index != -1)
                _children.splice(index, 1);
            
            if(item.isDynamic)
            {
                index = _dynamicItems.indexOf(item);
                if(index != -1)
                    _dynamicItems.splice(index, 1);
            }
            else
            {
                index = _staticItems.indexOf(item);
                if(index != -1)
                    _staticItems.splice(index, 1);
            }
            
            var n : uint = _children.length;
            
            for(var i:uint=0; i < n; i++)
            {
                index = 0;
                while((index = _children[i].behind.indexOf(item, index)) != -1)
                {
                    _children[i].behind.splice(index, 1);
                }
            }
            
            item.isoItem        = null;
            item.behind         = null;
            item.dynamicsBehind = null;
            item.visited        = false;
        }
        
        override public function updateDepth(item : IsoDisplayObject) : void
        {
            sort();
        }
        
        override public function sort() : void
        {
            _needSorting = true;
        }
    }
}