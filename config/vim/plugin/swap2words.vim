function! Swap2Words(line1,line2,word1,word2) abort
	echowindow a:line1
	echowindow a:line2
	echowindow a:word1
	echowindow a:word2
	
	let tmp1 = a:line1..","..a:line2..'s/'..a:word1..'/SWAP_WORD1/g'
	let tmp2 = a:line1..","..a:line2..'s/'..a:word2..'/SWAP_WORD2/g'
	let swap1 = a:line1..","..a:line2..'s/SWAP_WORD1/'..a:word2..'/g'
	let swap2 = a:line1..","..a:line2..'s/SWAP_WORD2/'..a:word1..'/g'

	echowindow tmp1
	echowindow tmp2
	echowindow swap1
	echowindow swap2

	execute tmp1
	execute tmp2
	execute swap1
	execute swap2
endfunction
command! -range -narg=* Swap2Words call Swap2Words(<line1>,<line2>,<f-args>)
