function __colorscheme_set -d 'Auxiliary function for colorscheme, duh!'
  switch (count $argv)
    case 5
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_color_param             $color
      set color $argv[2]
      set -g fish_color_command           $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_completion  $color
      set color $argv[3]
      set -g fish_color_quote             $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_pager_color_prefix      $color
      set color $argv[4]
      set -g fish_color_escape            $color
      set -g fish_color_autosuggestion    $color
      set -g fish_color_comment           $color
      set color $argv[5]
      set -g fish_color_end               $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$argv[5]

    case 4
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_color_param             $color
      set color $argv[2]
      set -g fish_color_command           $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_completion  $color
      set color $argv[3]
      set -g fish_color_quote             $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_autosuggestion    $color
      set color $argv[4]
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_end               $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$argv[4]

    case 3
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color
      set color $argv[2]
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_pager_color_completion  $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color
      set color $argv[3]
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$argv[3]

    case 2
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color
      set -g fish_pager_color_completion  $color
      set color $argv[2]
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$argv[2]

    case 1
      set color $argv[1]
      set -g fish_color_user              $color
      set -g fish_color_cwd               $color
      set -g fish_color_host              $color
      set -g fish_color_normal            $color
      set -g fish_pager_color_description $color
      set -g fish_pager_color_prefix      $color
      set -g fish_color_param             $color
      set -g fish_color_quote             $color
      set -g fish_color_command           $color --bold
      set -g fish_pager_color_completion  $color
      set -g fish_color_redirection       $color
      set -g fish_color_operator          $color
      set -g fish_pager_color_progress    $color
      set -g fish_color_end               $color
      set -g fish_color_autosuggestion    $color --bold
      set -g fish_color_match             $color
      set -g fish_color_history_current   $color
      set -g fish_color_cwd_root          $color --bold
      set -g fish_color_escape            $color
      set -g fish_color_comment           $color
      set -g fish_color_status            $color --bold
      set -g fish_pager_color_secondary   $color
      set -g fish_color_error             $color
      # Special
      set -g fish_color_valid_path        --underline
      set -g fish_color_search_match      --background=$argv[1]

  end
end
