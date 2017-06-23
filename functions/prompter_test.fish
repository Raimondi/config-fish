function prompter_test
  set outfile /tmp/.prompter_test.out
  set rightfile /tmp/.prompter_test.right
  #'error'\n'{'\n3 \
  #'error'\n'{1}'\n7 \
  #'error'\n' '\n17 \
  set tests \
     error\n'{foo?}'\n1 \
     error\n'{1??}'\n2 \
     error\n'{1::}'\n4 \
     error\n'{1}'\n5 \
     error\n'{}'\n6 \
     error\n'(user}'\n8 \
     error\n')'\n9 \
     error\n'(c:x)'\n10 \
     error\n'(c:?'\n11 \
     error\n'(foo)'\n12 \
     error\n'{'\n13 \
     error\n'('\n14 \
     error\n'(c:'\n15 \
     error\n'{1'\n16 \
     error\n'(c:red'\n18 \
     error\n'(time:"'\n19 \
     error\n'?'\n20 \
     error\n':'\n21 \
     error\n'}'\n22 \
     error\n'(?'\n23 \
     error\n'(c'\n24 \
     error\n'(c'\n24 \
     output\n'a'\na \
     output\n'{1?a:b}'\na \
     output\n'x{1?a}'\nxa \
     output\n'x{1:b}'\nx \
     output\n'{0?a:b}'\nb \
     output\n'x{0?a}'\nx \
     output\n'x{0:b}'\nxb \
     output\n'(user)'\n$USER \

  for test in $tests
    rm -f $outfile
    set test (echo $test)
    if test $test[1] = error
      set test_msg (printf "%-10s %-15s => %-15s" $test[1]: "'"$test[2]"'" $test[3])
      prompter $test[2] >$outfile ^&1
      set last_status $status
      if test $last_status -eq $test[3]
        set_color green
        echo -n $test_msg
        echo passed
        set_color normal
        set passed $passed "$test"
      else
        set_color red
        echo -n $test_msg
        echo failed with exit code $last_status
        set_color normal
        cat $outfile
        set failed $failed "$test"
      end
    else
      set test_msg (printf "%-10s %-15s => %-15s" $test[1]: "'"$test[2]"'" $test[3])
      echo -n $test[3] | tr -d \e >$rightfile
      prompter --nocolors -- $test[2] | tr -d \e >$outfile ^&1
      set result (cat $outfile)
      set last_status $status
      if begin
          test $last_status -eq 0 -a "$result" = "$test[3]"
          and cmp $rightfile $outfile
        end
        set_color green
        echo -n $test_msg
        set_color green
        echo passed
        set_color normal
        set passed $passed "$test"
      else
        set_color red
        echo -n $test_msg
        set_color red
        echo failed with exit code $last_status
        set_color normal
        diff -U 5 $rightfile $outfile
        set failed $failed "$test"
        #break
      end
    end
  end
  printf '\nOf a total of %s tests, %s passed and %s failed\n\n' (count $tests) (count $passed) (count $failed)
  #rm -f $outfile
end
