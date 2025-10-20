/* From cschuyle:

   I found this at https://codepen.io/btmbtm/pen/vdPzOa?editors=1111,
   which in turn I found from a comment in https://www.reddit.com/r/amazon/comments/7paenb/amazon_wishlist_web_scraper/,
   attributed to https://www.reddit.com/user/kjxymzy/

   Changes/fixes:
   - The Date Added extractor needed amending for the lists as they are on Jan 2, 2020, so I fixed it.
   - Quoted ASIN so it doesn't get interpreted by numbers when importing
   - Output just URL of image and item page
   - Output the list name also, to enable easy concatenation of lists
*/

/*

=== INSTRUCTIONS ===

1. Open Amazon wishlist page

2. Make sure all items are loaded. You may have to scroll for a long time if your list is long. Scroll until the **END OF LIST** marker is shown.

3. Once all items are loaded, copy and paste the script below into the console, followed by hitting the `enter`/`return` key
 - On Chrome console can be found via: ` Ctrl + Shift + J (Windows / Linux)` or `Cmd + Opt + J (Mac)`
 - On Safari via: `Option + Cmd + C`
 - On Firefox via: `Ctrl + Shift + K` or	`Cmd + Opt + K`


4. The page will turn into a formatted table of your items. You now have a few options:
 - select all the items w/ `ctrl + a` and paste it directly into an Excel sheet.
 - save the webpage as an HTML document/archive page/PDF (book marking will not work!)
 - other ideas I may not be thinking off
*/

function scrape() {

    var profileListName = document.querySelector("#profile-list-name").innerText;

    // Capture wishlist items
    var c = document.querySelectorAll(".g-item-sortable");
    var books = [];
    for (var i = 0; i < c.length; i++) {
        var book = {};
        var id = c[i].getAttribute("data-itemid");
        book["n"] = i;
        book["id"] = id;
        try {
            book["title"] = c[i].querySelector("#itemName_" + id).title;
        } catch (err) {
            book["title"] = "";
        }

        try {
            book["link"] = c[i].querySelector("#itemName_" + id).href || "";
        } catch (err) {
            book["link"] = "";
        }

        try {
            book["author"] = c[i].querySelector("#item-byline-" + id).innerText
                .replace("by ", "").replace(/\(.+?\)/, "");
        } catch (err) {
            book["author"] = "";
        }
        try {
            book["image"] = c[i].querySelector("#itemImage_" + id + " img").src;
        } catch (err) {
            book["image"] = "";
        }

        try {
            book["price"] = c[i].querySelector('.itemUsedAndNewPrice').innerText;
        } catch (err) {
            book["price"] = "";
        }

        try {
            var itemAddedText = c[i]
                .querySelector("#itemAddedDate_" + id)
                .innerText;
            var prefix = "Item added ";
            if (itemAddedText.indexOf(prefix) == 0) {
                itemAddedText = itemAddedText.slice(prefix.length);
            }
            book["itemAddedDate"] = itemAddedText;
        } catch (err) {
            book["itemAddedDate"] = "";
        }

        try {
            book["asin"] = JSON.parse(
                c[i].getAttribute("data-reposition-action-params")
            ).itemExternalId.match(/ASIN:(.+?)\|/)[1];
        } catch (err) {
            book["asin"] = "";
        }
        books.push(book);
    }

// Clear site
    document.body.innerText = "";


// Build table w/ wishlist items
    function maketd(val) {
        var td = document.createElement("td");
        td.innerHTML = val.trim();
        return td;
    }

    var table = document.createElement("table");
    table.style.margin = "10px";

    var head = document.createElement("tr");
    table.appendChild(head);

    var head_dateAdded = document.createElement("th");
    head_dateAdded.innerText = "Date Added";
    head.appendChild(head_dateAdded);

    var head_image = document.createElement("th");
    head_image.innerText = "Image URL";
    head.appendChild(head_image);

// var head_image = document.createElement("th");
// head_image.innerText = "Image (link)";
// head.appendChild(head_image);

    var head_title = document.createElement("th");
    head_title.innerText = "Title";
    head.appendChild(head_title);

    var head_author = document.createElement("th");
    head_author.innerText = "Author";
    head.appendChild(head_author);

    var head_asin = document.createElement("th");
    head_asin.innerText = "ASIN";
    head.appendChild(head_asin);

    var head_price = document.createElement("th");
    head_price.innerText = "Price";
    head.appendChild(head_price);

    var head_link = document.createElement("th");
    head_link.innerText = "Item URL";
    head.appendChild(head_link);

// var head_link = document.createElement("th");
// head_link.innerText = "Item (link)";
// head.appendChild(head_link);

    var head_list_name = document.createElement("th");
    head_list_name.innerText = "List Name";
    head.appendChild(head_list_name);

    for (var i = 0; i < books.length; i++) {
        let tr = document.createElement("tr");

        tr.appendChild(maketd(books[i].itemAddedDate));
        tr.appendChild(maketd(books[i].image));
        // tr.appendChild(maketd(`<a href='${books[i].image}'><img src=${books[i].image}></a>`));
        tr.appendChild(maketd(books[i].title));
        tr.appendChild(maketd(books[i].author));
        tr.appendChild(maketd(`'${books[i].asin}`));
        tr.appendChild(maketd(books[i].price));
        tr.appendChild(maketd(books[i].link));
        // tr.appendChild(maketd(`<a href='${books[i].link}'>Product Link</a>`));
        tr.appendChild(maketd(profileListName));

        table.appendChild(tr);
    }

    document.body.appendChild(table);
}

scrape();
