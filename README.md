# ptiff2doc

`ptiff2doc` is shell script which puts tiff files from a folder, together
into a PDF and/or DJVU file. It's assumed that the tiff files are pre-processed
with a tool like [ScanTailor](http://scantailor.org/). A hidden text layer
is added to the document PDF/DJVU, generated with `tesseract` (OCR).
This allows the PDF/DJVU file to be searchable (aka sandwichpdf).

`ptiff2doc` makes use of `parallel` to process the tiff files in parallel
and make use of several CPU cores. `ptiff2doc` is very resource hungry
(CPU and disk space). Expect about twice the size the folder with the
tiff files to be used for temporary processed files (they get removed
when the script finishes). The temporary folder is created in the current
working directory (cwd).

If you need more control over the created PDF/DJVU document,
it's recommended to use [gscan2pdf](http://gscan2pdf.sourceforge.net/).

`ptiff2doc` depends on many external tools (see below), for convenience the
needed packages to be installed in Fedora:

    dnf install parallel libtiff-tools tesseract netpbm-progs djvulibre \
    poppler-utils perl-Log-Log4perl gscan2pdf perl-File-Slurp perl-File-Temp \
    perl-PDF-API2 perl-Getopt-Long perl-Encode perl-Encode-Locale perl-TimeDate

## Usage
        ./ptiff2doc.sh [OPTIONS] [FOLDER WITH TIFF FILES]

        [FOLDER WITH TIFF FILES]
            a folder with .tif files, if folder is ommited
            the current working directory (cwd) is used.

    Options [default value]:
        -h | --help          This help
        -b | --docname       The basename of the output document [book]
        -d | --dpi           DPI setting for c44 [300]
        -j | --djvu          Create .djvu
        -p | --pdf           Create .pdf
        -a | --author        Author to be set in .pdf/.djvu
        -t | --title         Title to be set in .pdf/.djvu
        -l | --language      Language setting for tesseract [deu]
                             See 'tesseract --list-langs' for supported languages
                             deu = German
                             eng = English
                             fin = Finnish
                             for mixed language documents 'deu+eng' is also possible

## Needed tools

   * [parallel](http://www.gnu.org/software/parallel/)
   * [tiffcp](http://www.simplesystems.org/libtiff/)
   * [tesseract](https://github.com/tesseract-ocr/tesseract)
   * For DJVU documents
      * [tifftopnm](http://netpbm.sourceforge.net/)
      * [c44](http://djvu.sourceforge.net/)
      * [djvused](http://djvu.sourceforge.net/)
      * [djvm](http://djvu.sourceforge.net/)
   * For PDF documents
      * [pdfunite](http://poppler.freedesktop.org/)

## Needed Perl Libraries

   * [Log::Log4perl](http://search.cpan.org/dist/Log-Log4perl/)
   * [Gscan2pdf::Page](http://gscan2pdf.sourceforge.net)
   * [File::Slurp](http://search.cpan.org/dist/File-Slurp/)
   * [File::Temp](http://search.cpan.org/dist/File-Temp/)
   * [PDF::API2](http://search.cpan.org/dist/PDF-API2/)
   * [Getopt::Long](http://search.cpan.org/dist/Getopt-Long/)
   * [Encode](http://search.cpan.org/dist/Encode/)
   * [Encode::Locale](http://search.cpan.org/dist/Encode-Locale/)
   * [Date::Format](http://search.cpan.org/dist/TimeDate/)