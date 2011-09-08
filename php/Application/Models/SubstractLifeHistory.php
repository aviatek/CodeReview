<?php
/**
 * Substract life model
 * 
 * @category       Application
 * @package        Application_Model
 * @author         Bartosz Szymanski
 */

class Application_Models_SubstractLifeHistory extends Shard_Models_Shard_Abstract
{
    /**
     * Unique id
     * @var int
     */
    public $substractId;

    /**
     * Related user id
     * @var string
     */
    public $userId;
    
    /**
     * Number of lives to substract
     * 
     * @var int
     */
    public $livesCount;
    
    /**
     * Type of life substract
     * 
     * @var int
     */
    public $liveType;

    /**
     * Type of game
     * 
     * @var int
     */
    public $gameType;
    
    /**
     * World id
     * 
     * @var int
     */
    public $worldId;
    
    /**
     * Island id
     * 
     * @var int
     */
    public $islandId;
    
    /**
     * Level id
     * 
     * @var int
     */
    public $levelId;
    
    /**
     * @var int
     */
    public $timestamp;
}