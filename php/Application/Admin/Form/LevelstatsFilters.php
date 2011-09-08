<?php

class Application_Admin_Form_LevelstatsFilters extends Zend_Form
{
    private $filters;
    
    public function __construct($filters, $options = null)
    {
        $this->filters = $filters;
        parent::__construct($options);
    }

    public function init()
    {
        $this->setMethod(Zend_Form::METHOD_GET);
        $this->setName('levelsfilter');
        $this->setAction($this->getView()->baseUrl("admin/levelstats"));

        $elements = array();
        foreach($this->filters as $filter)
        {
            $el = new Zend_Form_Element_Text($filter['name']);
            $el->setLabel($filter['label']);
            $el->setAttrib("class", $filter['class']);
            $el->setAttrib("readonly","readonly");
            $this->addElement($el);
        }
        
        $el = new Zend_Form_Element_Select('type');
        $el->setLabel("Type: ");
        $el->addMultiOption("2","Overall");
        $el->addMultiOption("1","Relative");
        $el->setAttrib("class","filter");
        $this->addElement($el);
            
        $submit = new Zend_Form_Element_Submit('Generate');
        $submit->setLabel('Generate stats');
        $submit->setAttrib("class","button");
        $this->addElement($submit);
    }
}