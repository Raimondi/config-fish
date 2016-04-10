function fish_right_prompt --description 'Write out the right prompt'
  set_color 555
  date | tr -d '[:cntrl:]'
  set_color normal
end
