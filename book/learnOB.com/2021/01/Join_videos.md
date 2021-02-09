#   Join videos
28 January  2021
  
  $  cat mylist.txt
  
  file '/path/to/file1'
  
  file '/path/to/file2'
  
  file '/path/to/file3'
      
  $ ffmpeg -f concat -safe 0 -i mylist.txt -c copy output.mp4

