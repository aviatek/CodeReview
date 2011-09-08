<?php
/**
 * @category       Application
 * @package        Application_Model
 * @author         Bartosz Szymanski
 */

class Application_Models_User extends Shard_Models_Shard_Abstract
{
    /**
     * Premium coins value.
     * 
     * @var int
     */
    public $coins;
    
    /**
     * Unix timestamp when last bonus was added.
     * 
     * @var int
     */    
    public $lastDailyBonusTime;

    /**
     * Current bonus level - influent the daily bonus amount
     * 
     * @see Application_Configs_Constants::DAILY_BONUS_TIME_MIN
     * @see Application_Configs_Constants::DAILY_BONUS_TIME_MAX
     * @see Application_Configs_Constants::$DAILY_BONUS_VALUES
     * @var int
     */
    public $dailyBonusLevel;

    /**
     * Scores for each game types
     * 
     * 
     * @var array <Application_Models_ScoreChallenge | Application_Models_ScoreExplorer>
     */
    public $scores;

    /**
     * Random MD5 generated sig on login action, used to signing secured requests in session.
     * 
     * @var string
     */
    public $challangeKey;

    /**
     * Number of lives - automatically refilled.
     * 
     * @see Application_Configs_Constants::ADDING_LIVES_TIME
     * @var int
     */
    public $lives;

    /**
     * Premium lives bought by real cash.
     * 
     * @var int
     */
    public $livesBought;

    /**
     * Unix timestamp - time of last life auto refill.
     * 
     * @var int
     */
    public $lastLivesTime;

    /**
     * Number of lives from friends.
     * 
     * @var int
     */
    public $livesFromFriends;

    /**
     * Number of spins available to use in daily lottery.
     * 
     * @var int
     */
    public $spinsLeft;

    /**
     * Flags to use within flash.
     * 
     * @var int
     */
    public $flags;

    /**
     * First name taken from social platform.
     * 
     * @var string
     */
    public $firstName;
    
    /**
     * Last name taken from social platform.
     * 
     * @var string
     */
    public $lastName;
    
    /**
     * Last tournament scores user has seen.
     * 
     * @var int
     */
    
    public $lastTournamentSeen;

    /**
     * Timestamp of uninstalling application.
     * 
     * @var int
     */

    public $removalTime;
    
    /**
     * Timestamp of creating user (registration).
     * 
     * @var int
     */

    public $registerTime;
    
    /**
     * Timestamp of last login.
     * 
     * @var int
     */

    public $lastLoginTime;

    /**
     * Add lives to given user based on last login time.
     * 
     * @see Application_Configs_Constants::ADDING_LIVES_TIME
     * @return int seconds left to add next live
     */
    public function addLives()
    {
        $currentTime = time();
        
        /* time difference in seconds between last login */
        $timediff     = $currentTime - $this->lastLivesTime;
        $livesAddTime = Application_Configs_Constants::ADDING_LIVES_TIME;
        $timeMod      = $timediff % $livesAddTime;

        if($timediff >= $livesAddTime && $this->lives < Application_Configs_Constants::MAX_LIVES)
        {
            /* Number of lives to add */
            $livesAdd = intval($timediff / $livesAddTime);
            $this->lives += $livesAdd;

            /* Limit lives */
            if($this->lives >= Application_Configs_Constants::MAX_LIVES)
                $this->lives = Application_Configs_Constants::MAX_LIVES;

            $this->lastLivesTime = $currentTime - $timeMod;
        }

        /* return time in seconds left to next live for flash timer */
        if($this->lives < Application_Configs_Constants::MAX_LIVES)
            return $livesAddTime - $timeMod;
        else
            return 0;
    }
    
    /**
     * Handles daily bonus calculations
     * 
     * @see Application_Configs_Constants::DAILY_BONUS_TIME_MIN
     * @see Application_Configs_Constants::DAILY_BONUS_TIME_MAX
     * @see Application_Configs_Constants::$DAILY_BONUS_VALUES
     * @return int daily bonus amount
     */
    public function handleDailyBonus($numFriends)
    {
        $bonusAmount       = 0;
        $currentTime       = time();
        $timeFromLastBonus = $currentTime - $this->lastDailyBonusTime;

        if($timeFromLastBonus >= Application_Configs_Constants::DAILY_BONUS_TIME_MIN)
        {
            /* Daily bonus calculations */
            $this->lastDailyBonusTime = $currentTime;

            /* Reset bonus level if was absent for too long */
            if($timeFromLastBonus >= Application_Configs_Constants::DAILY_BONUS_TIME_MAX)
            {
                $this->dailyBonusLevel = 1;
            }
            else
            {
                /* Increase bonus level for continues daily login */
                if($this->dailyBonusLevel < sizeof(Application_Configs_Constants::$DAILY_BONUS_VALUES))
                    $this->dailyBonusLevel++;
            }

            /* Calculate bonus amount */
            $bonusAmount  = Application_Configs_Constants::$DAILY_BONUS_VALUES[$this->dailyBonusLevel - 1];
            $bonusAmount += $numFriends * Application_Configs_Constants::$DAILY_BONUS_PER_FRIEND_VALUE;
            $this->coins += $bonusAmount;

            /* Adds 1 free spin if 0 left */
            if($this->spinsLeft == 0)
                $this->spinsLeft = 1;
        }

        return $bonusAmount;
    }

    public function initLastDailyBonusTime()
    {
        $this->lastDailyBonusTime = time() - Application_Configs_Constants::DAILY_BONUS_TIME_MIN + 10;
    }
}