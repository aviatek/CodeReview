package de.softgames.iso.astar
{
    import de.softgames.iso.events.AStarEvent;
    import de.softgames.model.node.Node;
    import de.softgames.model.node.NodeCollection;
    import de.softgames.model.node.NodesPath;
    
    import flash.events.EventDispatcher;
    
    /**
     * AStar path finding algorith implementation.
     */
    public class AStar extends EventDispatcher
    {
        public static const MAX_RECURSION_DEPTH          : uint = 3000;
        public static const MAX_RECURSION_DEPTH_PER_LOOP : uint = 500;
        
        private var _startNode      : Node;
        private var _endNode        : Node;
        private var _openedList     : Array;
        private var _closedList     : Array;
        private var _straightCost   : Number = 1;
        private var _diagCost       : Number = Math.SQRT2;
        private var _nodes          : NodeCollection;
        private var _depth          : uint;
        private var _currentDepth   : uint;
        private var _tempStartNode  : Node;
        
        public var defaultHeuristic : Function = diagonalHeuristic;
        
        
        public function AStar()
        {
            
        }
        
        /**
         * Performs A* algorithm.
         * 
         * @param heuristic Heuristic used in algorithm.
         * @return Founded <code>Path</code> instance, otherwise <code>null</code>.
         */
        private function _searchPath(heuristic : Function) : NodesPath
        {
            var node : Node = _tempStartNode;
            
            while(node != _endNode)
            {
                var sx : int = Math.max(0, node.x - 1);
                var ex : int = Math.min(_nodes.numNodesX - 1, node.x + 1);
                var sy : int = Math.max(0, node.y - 1);
                var ey : int = Math.min(_nodes.numNodesY - 1, node.y + 1);
                
                for(var i:int = sx; i <= ex; i++)
                {
                    for(var j:int = sy; j <= ey; j++)
                    {
                        if(_depth >= MAX_RECURSION_DEPTH)
                        {
                            trace("AStar: MAX_RECURSION_DEPTH reached!");
                            dispatchEvent(new AStarEvent(AStarEvent.MAX_RECURSION_DEPTH_REACHED));
                            trace("LOOP QUIT 1");
                            return null;
                        }
                        
                        if(this._currentDepth >= MAX_RECURSION_DEPTH_PER_LOOP)
                        {
                            trace("AStar: MAX_RECURSION_DEPTH_PER_LOOP reached!");
                            _tempStartNode = node;
                            _currentDepth = 0;
                            return this._searchPath(heuristic);
                        }
                        
                        _currentDepth++;
                        _depth++;
                        
                        var test : Node = _nodes.getNodeAt(i, j);
                        
                        if(test == node || !test.walkable || isWallBetweenNodes(node, test))
                        {
                            continue;
                        }
                        
                        var cost : Number = this._diagCost;
                        
                        /* Going straight */
                        if((node.x == test.x) || (node.y == test.y))
                        {
                            cost = _straightCost;
                        }
                        /* Cutting corner */
                        else if(isCornerUnwalkable(_nodes, node, test))
                        {
                            continue;
                        }
                        
                        var g : Number = node.g + cost * test.costMultiplier;
                        var h : Number = heuristic(test, _endNode);
                        var f : Number = g + h;
                        
                        if(_isOpened(test) || _isClosed(test))
                        {
                            if(test.f > f)
                            {
                                test.f = f;
                                test.g = g;
                                test.h = h;
                                test.parent = node;
                            }
                        }
                        else
                        {
                            test.f = f;
                            test.g = g;
                            test.h = h;
                            test.parent = node;
                            _openedList.push(test);
                        }
                    }
                }
                
                _closedList.push(node);
                
                if(_openedList.length == 0)
                {
                    trace("Path not found!!");
                    trace("LOOP QUIT 4");
                    return null;
                }
                
                _openedList.sortOn("f", Array.NUMERIC);
                node = _openedList.shift() as Node;
            }
            
            return _buildPath();
        }
        
        private function _buildPath() : NodesPath
        {
            var p    : Array = [];
            var node : Node  = _endNode;
            p.push(node);
            
            while(node !== _startNode && node.parent)
            {
                node = node.parent;
                p.unshift(node);
            }
            
            return new NodesPath(p);
        }
        
        private function _isOpened(node : Node) : Boolean
        {
            var num : uint = _openedList.length;
            
            for(var i:uint=0; i < num; i++)
                if(_openedList[i] == node)
                    return true;
            
            return false;
        }
        
        private function _isClosed(node : Node) : Boolean
        {
            var num : uint = _closedList.length;
            
            for(var i:uint=0; i < num; i++)
                if(_closedList[i] == node)
                    return true;
            
            return false;
        }
        
        //----------------------------------------
        // Public methods
        //----------------------------------------
        
        /**
         * Tries to find a path from the start node to the end node.
         * 
         * @param start Start node.
         * @param end End node.
         * @param engine IsometricEngine instance where the path will be searched.
         * @return <code>null</code> when path can't be found, otherwise founded <code>Path</code> instance.
         */
        public function findPath(startNode : Node, endNode : Node, nodes : NodeCollection) : NodesPath
        {
            _depth         = 0;
            _currentDepth  = 0;
            _nodes         = nodes;
            _openedList    = [];
            _closedList    = [];
            _startNode     = _nodes.getNodeAt(startNode.x, startNode.y);
            _endNode       = _nodes.getNodeAt(endNode.x, endNode.y);
            _tempStartNode = _startNode;
            
            var heuristic : Function = defaultHeuristic;
            
            _startNode.g = 0;
            _startNode.h = heuristic(_startNode, _endNode);
            _startNode.f = _startNode.g + _startNode.h;
            
            var path : NodesPath = _searchPath(heuristic);
            
            if(path)
            {
                var e : AStarEvent = new AStarEvent(AStarEvent.PATH_FOUND);
                e.path = path;
                dispatchEvent(e);
            }
            else
            {
                dispatchEvent(new AStarEvent(AStarEvent.PATH_NOT_FOUND));
            }
            
            return path;
        }
        
        public function manhattanHeuristic(node : Node, endNode : Node) : Number
        {
            return Math.abs(node.x - _endNode.x) * _straightCost + 
                Math.abs(node.y + _endNode.y) * _straightCost;
        }
        
        public function diagonalHeuristic(node : Node, endNode : Node) : Number
        {
            var dx       : Number = Math.abs(node.x - _endNode.x);
            var dz       : Number = Math.abs(node.y - _endNode.y);
            var diag     : Number = Math.min(dx, dz);
            var straight : Number = dx + dz;
            
            return _diagCost * diag + _straightCost * (straight - 2 * diag);
        }
        
        public function euclidianHeuristic(node : Node, endNode : Node) : Number
        {
            var dx : Number = node.x - _endNode.x;
            var dz : Number = node.y - _endNode.y;
            
            return Math.sqrt(dx * dx + dz * dz) * _straightCost;
        }
        
        
        //----------------------------------------
        // Static methods
        //----------------------------------------
        
        public static function isCornerUnwalkable(nodes : NodeCollection, firstNode : Node, secondNode : Node) : Boolean
        {
            var firstDiagNode  : Node    = nodes.getNodeAt(firstNode.x, secondNode.y);
            var secondDiagNode : Node    = nodes.getNodeAt(secondNode.x, firstNode.y);
            var stdCorner      : Boolean = !firstDiagNode.walkable || !secondDiagNode.walkable;
            
            return stdCorner || 
                   isWallBetweenNodes(firstNode, firstDiagNode) || 
                   isWallBetweenNodes(firstNode, secondDiagNode) ||
                   isWallBetweenNodes(secondNode, firstDiagNode) || 
                   isWallBetweenNodes(secondNode, secondDiagNode) ||
                   isWallBetweenNodes(firstDiagNode, secondDiagNode) ||
                   isWallBetweenNodes(firstNode, secondNode);
        }
        
        /**
         * Checks if there is any wall between two nodes.
         * 
         * return <code>true</code> if there is any wall; otherwise <code>false</code>
         */
        public static function isWallBetweenNodes(firstNode : Node, secondNode : Node) : Boolean
        {
            if((!firstNode.wallFlag && !secondNode.wallFlag))
            {
                return false;
            }
            
            // Going along y axis: 
            if(firstNode.x == secondNode.x)
            {
                if(firstNode.y < secondNode.y)
                {
                    return !firstNode.canWalkBottom || !secondNode.canWalkTop;
                }
                else if(firstNode.y > secondNode.y)
                {
                    return !firstNode.canWalkTop || !secondNode.canWalkBottom;
                }
            }
            // Going along x axis: 
            else if(firstNode.y == secondNode.y)
            {
                if(firstNode.x < secondNode.x)
                {
                    return !firstNode.canWalkRight || !secondNode.canWalkLeft;
                }
                else if(firstNode.x > secondNode.x)
                {
                    return !firstNode.canWalkLeft || !secondNode.canWalkRight;
                }
            }
            //Going diagonal:
            else if(firstNode.y > secondNode.y)
            {
                if(firstNode.x < secondNode.x)
                {
                    return !firstNode.canWalkTop || !firstNode.canWalkRight || !secondNode.canWalkLeft || !secondNode.canWalkBottom;
                }
                else
                {
                    return !firstNode.canWalkLeft || !firstNode.canWalkTop || !secondNode.canWalkRight || !secondNode.canWalkBottom;
                }
            }
            else
            {
                if(firstNode.x < secondNode.x)
                {
                    return !firstNode.canWalkBottom || !firstNode.canWalkRight || !secondNode.canWalkLeft || !secondNode.canWalkTop;
                }
                else
                {
                    return !firstNode.canWalkBottom || !firstNode.canWalkLeft || !secondNode.canWalkTop || !secondNode.canWalkRight;
                }
            }
            
            return false;
        }
    }
}