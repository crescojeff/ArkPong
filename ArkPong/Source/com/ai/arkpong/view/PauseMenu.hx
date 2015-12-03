package com.ai.arkpong.view;
import haxe.ui.toolkit.containers.ExpandablePanel;
import haxe.ui.toolkit.controls.Button;
/**
A displayable and actionable view element that provides pause/resume/reset options to the player
**/
class PauseMenu extends ArkPongMovieClip{


    private var mv_rResumeButton:Button;
    private var mv_rResetButton:Button;

    public function new() {
    }

    public function getResumeButton():Button{
        return mv_rResumeButton;
    }
    public function getResetButton():Button{
        return mv_rResetButton;
    }

}
