package pl.deluxe.model
{
    import flash.geom.Point;
    
    /**
     * Class for handling model of a hexagonal grid.
     */
    public class NodesGrid
    {
        private var _grid    : Array;
        private var _numCols : uint;
        private var _numRows : uint;
        
        /**
         * Constructor.
         * 
         * @param numCols Number of columns in a grid.
         * @param numRows Number of rows in a grid.
         */
        public function NodesGrid(numCols : uint, numRows : uint)
        {
            _grid = [];
            _numCols = numCols;
            _numRows = numRows;
        }
        
        public function getNodeAt(x : int, y : int) : Node
        {
            if(x < 0 || x >= numCols || y < 0 || y >= numRows)
                return null;
            
            if(!_grid[x]) _grid[x] = [];
            
            return _grid[x][y];
        }
        
        public function setNode(x : int, y : int, node : Node) : void
        {
            if(!_grid[x]) _grid[x] = [];
            _grid[x][y] = node;
        }
        
        /**
         * Swaps to nodes.
         */
        public function swapNodes(firstNode : Node, secondNode : Node) : void
        {
            _grid[firstNode.x][firstNode.y] = secondNode;
            _grid[secondNode.x][secondNode.y] = firstNode;
            
            var x : int = firstNode.x;
            var y : int = firstNode.y;
            
            firstNode.x = secondNode.x;
            firstNode.y = secondNode.y;
            secondNode.x = x;
            secondNode.y = y;
        }
        
        /**
         * Calculates direction between two nodes.
         * 
         * @return Direction.
         * @see pl.deluxe.model.TraverseDirection
         */
        public function getDirectionBetweenNodes(firstNode : Node, secondNode : Node) : int
        {
            for(var i:uint=0; i < 6; i++)
                if(getNodeNextTo(firstNode, i) == secondNode)
                    return i;
            
            return -1;
        }
        
        public function getNodeTopLeftTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.TOP_LEFT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeTopRightTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.TOP_RIGHT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeLeftTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.LEFT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeRightTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.RIGHT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeBottomLeftTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.BOTTOM_LEFT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeBottomRightTo(node : Node) : Node
        {
            var cords : Point = getNodeCordsNextTo(node, TraverseDirection.BOTTOM_RIGHT);
            return cords ? getNodeAt(cords.x, cords.y) : null;
        }
        
        public function getNodeNextTo(node : Node, direction : uint) : Node
        {
            var matched : Node;
            
            switch(direction)
            {
                case TraverseDirection.BOTTOM_LEFT:
                    matched = getNodeBottomLeftTo(node);
                break;
                case TraverseDirection.BOTTOM_RIGHT:
                    matched = getNodeBottomRightTo(node);
                break;
                case TraverseDirection.LEFT:
                    matched = getNodeLeftTo(node);
                break;
                case TraverseDirection.RIGHT:
                    matched = getNodeRightTo(node);
                break;
                case TraverseDirection.TOP_LEFT:
                    matched = getNodeTopLeftTo(node);
                break;
                case TraverseDirection.TOP_RIGHT:
                    matched = getNodeTopRightTo(node);
                break;
                default:
                    throw new Error("Unsupported direction: " + direction);
                break;
            }
            
            return matched;
        }
        
        public function getNodeCordsNextTo(node : Node, direction : uint) : Point
        {
            switch(direction)
            {
                case TraverseDirection.BOTTOM_LEFT:
                    if(node.y == numRows-1)
                        return null;
                    
                    if(node.y%2 != 0)
                    {
                        return new Point(node.x, node.y+1);
                    }
                    else
                    {
                        if(node.x == 0)
                            return null;
                        else
                            return new Point(node.x-1, node.y+1);
                    }
                    
                    return null;
                break;
                case TraverseDirection.BOTTOM_RIGHT:
                    if(node.y == numRows-1)
                        return null;
                    
                    if(node.y%2 != 0)
                    {
                        if(node.x == numCols-1)
                            return null;
                        else
                            return new Point(node.x+1, node.y+1);
                    }
                    else
                    {
                        return new Point(node.x, node.y+1);
                    }
                    
                    return null;
                break;
                case TraverseDirection.LEFT:
                    if(node.x == 0)
                        return null;
                    
                    return new Point(node.x-1, node.y);
                break;
                case TraverseDirection.RIGHT:
                    if(node.x == numCols-1)
                        return null;
                    
                    return new Point(node.x+1, node.y);
                break;
                case TraverseDirection.TOP_LEFT:
                    if(node.y == 0)
                        return null;
                    
                    if(node.y%2 != 0)
                    {
                        return new Point(node.x, node.y-1);
                    }
                    else
                    {
                        if(node.x == 0)
                            return null;
                        else
                            return new Point(node.x-1, node.y-1);
                    }
                    
                    return null;
                break;
                case TraverseDirection.TOP_RIGHT:
                    if(node.y == 0)
                        return null;
                    
                    if(node.y%2 != 0)
                    {
                        if(node.x == numCols-1)
                            return null;
                        else
                            return new Point(node.x+1, node.y-1);
                    }
                    else
                    {
                        return new Point(node.x, node.y-1);
                    }
                    
                    return null;
                break;
                default:
                    throw new Error("Unsupported direction: " + direction);
                break;
            }
            
            return null;
        }
        
        /**
         * Gets all nodes that are the same color in horizontal (-) direction.
         * 
         * @param node Start node.
         * @param includeStartNode If <code>true</code> then start node will be added to the output list.
         * @return List of all nodes of the same color in horizontal direction.
         */
        public function getNodesHorizontal(node : Node, includeStartNode : Boolean = true) : Array
        {
            var list : Array = [];
            if(includeStartNode) list.push(node);
            numNodesInline(node, TraverseDirection.LEFT, list);
            numNodesInline(node, TraverseDirection.RIGHT, list);
            return list;
        }
        
        /**
         * Gets all nodes that are the same color in diagonal left (\) direction.
         * 
         * @param node Start node.
         * @param includeStartNode If <code>true</code> then start node will be added to the output list.
         * @return List of all nodes of the same color in diagonal left direction.
         */
        public function getNodesDiagonalLeft(node : Node, includeStartNode : Boolean = true) : Array
        {
            var list : Array = [];
            if(includeStartNode) list.push(node);
            numNodesInline(node, TraverseDirection.TOP_LEFT, list);
            numNodesInline(node, TraverseDirection.BOTTOM_RIGHT, list);
            return list;
        }
        
        /**
         * Gets all nodes that are the same color in diagonal right (/) direction.
         * 
         * @param node Start node.
         * @param includeStartNode If <code>true</code> then start node will be added to the output list.
         * @return List of all nodes of the same color in diagonal right direction.
         */
        public function getNodesDiagonalRight(node : Node, includeStartNode : Boolean = true) : Array
        {
            var list : Array = [];
            if(includeStartNode) list.push(node);
            numNodesInline(node, TraverseDirection.TOP_RIGHT, list);
            numNodesInline(node, TraverseDirection.BOTTOM_LEFT, list);
            return list;
        }
        
        /**
         * Counts node of the same color in horizontal (-) direction.
         * 
         * @param node Start node.
         * @return Number of nodes of the same color in horizontal direction.
         */
        public function numNodesHorizontal(node : Node) : uint
        {
            var num : uint = 1;
            num += numNodesInline(node, TraverseDirection.LEFT);
            num += numNodesInline(node, TraverseDirection.RIGHT);
            return num;
        }
        
        /**
         * Counts node of the same color in diagonal left (\) direction.
         * 
         * @param node Start node.
         * @return Number of nodes of the same color in diagonal left direction.
         */
        public function numNodesDiagonalLeft(node : Node) : uint
        {
            var num : uint = 1;
            num += numNodesInline(node, TraverseDirection.TOP_LEFT);
            num += numNodesInline(node, TraverseDirection.BOTTOM_RIGHT);
            return num;
        }
        
        
        /**
         * Counts node of the same color in diagonal right (/) direction.
         * 
         * @param node Start node.
         * @return Number of nodes of the same color in diagonal right direction.
         */
        public function numNodesDiagonalRight(node : Node) : uint
        {
            var num : uint = 1;
            num += numNodesInline(node, TraverseDirection.TOP_RIGHT);
            num += numNodesInline(node, TraverseDirection.BOTTOM_LEFT);
            return num;
        }
        
        /**
         * Counts node of the same color in provided direction.
         * 
         * @param startNode Start node.
         * @param direction Direction of traverse.
         * @param visitedNodes List of visited nodes.
         * @return Number of nodes of the same color in diagonal left direction.
         * 
         * @see pl.deluxe.model.TraverseDirection
         */
        public function numNodesInline(startNode : Node, 
                                       direction : int, 
                                       visitedNodes : Array = null) : uint
        {
            var n     : uint = 0;
            var node  : Node = startNode;
            var color : String = startNode.color;
            
            if(!node.canBeBlobbed || node.isUmbrella)
                return 0;
            
            do
            {
                node = getNodeNextTo(node, direction);
                
                if(node && node.canBeBlobbed && !node.isUmbrella && (node.color == color))
                {
                    if(visitedNodes) visitedNodes.push(node);
                    n++;
                }
                else
                {
                    break;
                }
            }
            while(node);
            
            return n;
        }
        
        /**
         * Checks if nodes adjoints to eachother.
         */
        public function nodesAdjoint(firstNode : Node, secondNode : Node) : Boolean
        {
            return (getNodeBottomLeftTo(secondNode)    == firstNode || 
                    getNodeBottomRightTo(secondNode) == firstNode || 
                    getNodeLeftTo(secondNode) == firstNode || 
                    getNodeRightTo(secondNode) == firstNode || 
                    getNodeTopLeftTo(secondNode) == firstNode || 
                    getNodeTopRightTo(secondNode) == firstNode);
        }
        
        public function get numCols() : uint
        {
            return _numCols;
        }

        public function get numRows() : uint
        {
            return _numRows;
        }
    }
}