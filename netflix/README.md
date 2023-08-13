## Requirements:

1. `python3`


2. Install required libraries
    ```
    $ pip install requirements.txt
    ```

## Usage

1. Login to your Netflix in a browser, go to the DVD queue, and from the browser's **File** menu select **Save As ...** complete web page. This will produce the output file `DVD Netflix.html`


2. Run the Extract script
    ```console
    $ ./extract.sh
    ```

    This will produce the output files:
    
        netflix-athome.txt
        netflix-queue.txt
        netflix-saved.txt
    
    **_NOTE_** that Netflix has been removing the **Saved** section from the queue page during 2023. If the section is not there the output file will be empty.