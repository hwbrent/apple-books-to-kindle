# apple-books-to-kindle

Basically I recently got a Kindle and wanted to put some books on it. I had some in the Books app on my Macbook, so dragged and dropped them from Books onto the Kindle. But KOReader wouldn't recognise them. Claude said this:

> That’s almost certainly because Apple Books stores EPUBs as unzipped folders named something like book.epub rather than as a single file. When you drag them out, you copy the folder itself. KOReader sees a directory, so it lets you browse into it. The PDF worked because it’s a real single file.
> You need to zip each folder back into a proper EPUB. Copy one of the folders from the Kindle (or from Books) to somewhere on your Mac, then in Terminal:
> ```bash
> cd ~/Desktop/mybook.epub
> zip -X0 ../mybook-fixed.epub mimetype
> zip -Xr9D ../mybook-fixed.epub . -x mimetype
> ```
> The mimetype file has to go in first and uncompressed, which is why it’s two commands. Copy mybook-fixed.epub to your Kindle’s books folder and delete the old folder version.

So I asked it to generate a script, and it spat out [fix_epubs.sh](fix_epubs.sh)
