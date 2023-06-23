if [ ! -e ~/.local/bin/yt-dlp ]; then
    wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp --output-document ~/.local/bin/yt-dlp
    chmod a+rx ~/.local/bin/yt-dlp
fi 
