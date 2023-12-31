## Requirements:

1. `python3`


2. Install required libraries
    ```
    $ pip install requirements.txt
    ```

3. `jq`

## Usage

1. Login to your Netflix in a browser, go to the DVD queue, and from the browser's **File** menu select **Save As ...** complete web page. This will produce the output file `DVD Netflix.html`


2. Run the Extract script. Provide the second argument if the exported HTML file is not in your current directory.
    ```console
    $ ./extract.sh [DVD Netflix.html file location]
    ```

    This will produce the output files:
    
        netflix-athome.json
        netflix-queue.json
        netflix-saved.json
    
        netflix-athome.csv
        netflix-queue.csv
        netflix-saved.csv
    
        netflix-athome.txt
        netflix-queue.txt
        netflix-saved.txt
    
    **_NOTE_** that Netflix has been removing the **Saved** section from the queue page during 2023. If the section is not there the output file will be empty.