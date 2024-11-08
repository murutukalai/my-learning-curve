Here's a Rust code snippet to generate a PDF using the `printpdf` crate to replicate the layout of your attached invoice image. This example focuses on structure and includes placeholders for data. You'll need to install the latest version of `printpdf` in your `Cargo.toml` file.

Add `printpdf` dependency to `Cargo.toml`:
```toml
[dependencies]
printpdf = "0.8.2" # Make sure to use the latest version available
```

And here's the Rust code:

```rust
use printpdf::*;
use std::fs::File;
use std::io::BufWriter;
use std::convert::TryInto;

fn main() {
    // Set up the PDF document
    let (doc, page1, layer1) = PdfDocument::new("Invoice", Mm(210.0), Mm(297.0), "Layer 1");

    // Get the first page and layer
    let current_layer = doc.get_page(page1).get_layer(layer1);

    // Define text styles
    let font = doc.add_builtin_font(BuiltinFont::HelveticaBold).unwrap();
    let regular_font = doc.add_builtin_font(BuiltinFont::Helvetica).unwrap();
    let font_size_title = 20;
    let font_size_body = 10;

    // Set colors
    let color = Color::Rgb(Rgb::new(0.2, 0.2, 0.2, None));
    let header_color = Color::Rgb(Rgb::new(0.4, 0.1, 0.3, None));

    // Draw header
    current_layer.set_fill_color(header_color);
    current_layer.add_shape(Rectangle::new(Mm(0.0), Mm(270.0), Mm(210.0), Mm(27.0), true, true, false));

    // Add invoice title
    current_layer.use_text("INVOICE", font_size_title, Mm(160.0), Mm(282.0), &font);

    // Add invoice details
    current_layer.use_text("Invoice Number:", font_size_body, Mm(150.0), Mm(272.0), &regular_font);
    current_layer.use_text("#202409001", font_size_body, Mm(180.0), Mm(272.0), &regular_font);

    current_layer.use_text("Invoice Date:", font_size_body, Mm(150.0), Mm(267.0), &regular_font);
    current_layer.use_text("Apr 18, 2024", font_size_body, Mm(180.0), Mm(267.0), &regular_font);

    // Add recipient details
    current_layer.use_text("BILL TO:", font_size_body, Mm(10.0), Mm(250.0), &font);
    current_layer.use_text("Jane Smith", font_size_body, Mm(10.0), Mm(245.0), &regular_font);
    current_layer.use_text("janesmith@email.com", font_size_body, Mm(10.0), Mm(240.0), &regular_font);
    current_layer.use_text("+91 - 1234567891", font_size_body, Mm(10.0), Mm(235.0), &regular_font);
    current_layer.use_text("123/225, x floor, B city", font_size_body, Mm(10.0), Mm(230.0), &regular_font);
    current_layer.use_text("Y Country - 532654", font_size_body, Mm(10.0), Mm(225.0), &regular_font);
    current_layer.use_text("33GHTAA0000A1Z6", font_size_body, Mm(10.0), Mm(220.0), &regular_font);

    // Add table headers
    current_layer.use_text("S.No", font_size_body, Mm(10.0), Mm(200.0), &font);
    current_layer.use_text("Title", font_size_body, Mm(30.0), Mm(200.0), &font);
    current_layer.use_text("Qty", font_size_body, Mm(100.0), Mm(200.0), &font);
    current_layer.use_text("Price", font_size_body, Mm(120.0), Mm(200.0), &font);
    current_layer.use_text("Total", font_size_body, Mm(140.0), Mm(200.0), &font);

    // Add items to the table
    let items = vec![
        ("01", "Banner Design", "01", "00.00", "00.00"),
        ("02", "Website designing", "01", "00.00", "00.00"),
        ("03", "API Integration work", "01", "00.00", "00.00"),
        ("04", "Website designing", "01", "00.00", "00.00"),
        ("05", "Site Updated", "01", "00.00", "00.00"),
        ("06", "Website designing", "01", "00.00", "00.00"),
    ];

    let mut y_position = 190.0;
    for (sno, title, qty, price, total) in items {
        current_layer.use_text(sno, font_size_body, Mm(10.0), Mm(y_position), &regular_font);
        current_layer.use_text(title, font_size_body, Mm(30.0), Mm(y_position), &regular_font);
        current_layer.use_text(qty, font_size_body, Mm(100.0), Mm(y_position), &regular_font);
        current_layer.use_text(price, font_size_body, Mm(120.0), Mm(y_position), &regular_font);
        current_layer.use_text(total, font_size_body, Mm(140.0), Mm(y_position), &regular_font);
        y_position -= 10.0;
    }

    // Add payment info
    current_layer.use_text("PAYMENT INFO:", font_size_body, Mm(10.0), Mm(100.0), &font);
    current_layer.use_text("A/C Name: Holder Name Here", font_size_body, Mm(10.0), Mm(95.0), &regular_font);
    current_layer.use_text("A/C No: 11231546879", font_size_body, Mm(10.0), Mm(90.0), &regular_font);
    current_layer.use_text("IFS Code: ICICI1231215", font_size_body, Mm(10.0), Mm(85.0), &regular_font);
    current_layer.use_text("Pan No: Ghdng1234H", font_size_body, Mm(10.0), Mm(80.0), &regular_font);
    current_layer.use_text("GST No: 22AAAAA0000A1Z5", font_size_body, Mm(10.0), Mm(75.0), &regular_font);

    // Add summary totals
    current_layer.use_text("Subtotal", font_size_body, Mm(150.0), Mm(60.0), &regular_font);
    current_layer.use_text("00.00", font_size_body, Mm(180.0), Mm(60.0), &regular_font);

    current_layer.use_text("Tax", font_size_body, Mm(150.0), Mm(55.0), &regular_font);
    current_layer.use_text("00.00", font_size_body, Mm(180.0), Mm(55.0), &regular_font);

    current_layer.use_text("Roundoff", font_size_body, Mm(150.0), Mm(50.0), &regular_font);
    current_layer.use_text("00.00", font_size_body, Mm(180.0), Mm(50.0), &regular_font);

    current_layer.use_text("Grand Total", font_size_body, Mm(150.0), Mm(40.0), &font);
    current_layer.use_text("00.00", font_size_body, Mm(180.0), Mm(40.0), &font);

    // Add note
    current_layer.use_text("NOTE:", font_size_body, Mm(10.0), Mm(20.0), &font);
    current_layer.use_text("We declare that invoice shows the actual price of the goods, Described and that all particulars are true and correct.", font_size_body, Mm(10.0), Mm(15.0), &regular_font);
    current_layer.use_text("*** CHEQUE Bounce Charges will be levied based in bank debits***", font_size_body, Mm(10.0), Mm(10.0), &regular_font);

    // Save the PDF file
    doc.save(&mut BufWriter::new(File::create("invoice.pdf").unwrap())).unwrap();
}
```

This code creates a simple layout similar to the attached image, replicating the basic structure, headers, invoice items, and summary. Adjust the spacing, colors, and styles as needed to get the exact design you want. This example uses `Mm` units for measurements and the Helvetica font. You may need to fine-tune the positioning to achieve a closer match to your image.


________


Here's an HTML version of the invoice layout in your image. This uses basic HTML and CSS to replicate the structure and styling as closely as possible. You can save this as an `.html` file and open it in a browser to view it.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        .container {
            width: 80%;
            margin: 20px auto;
            background: #fff;
            padding: 20px;
            box-shadow: 0px 0px 10px rgba(0,0,0,0.1);
        }
        .header {
            background: #422146;
            padding: 20px;
            color: white;
            text-align: right;
        }
        .header h1 {
            margin: 0;
            font-size: 36px;
        }
        .invoice-info {
            display: flex;
            justify-content: space-between;
            margin: 20px 0;
        }
        .invoice-info div {
            font-size: 14px;
        }
        .invoice-info h2 {
            font-size: 18px;
            color: #422146;
        }
        .table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }
        .table th, .table td {
            padding: 12px;
            border: 1px solid #ddd;
            text-align: left;
        }
        .table th {
            background-color: #422146;
            color: white;
        }
        .table td {
            background-color: #fdf4fa;
        }
        .payment-info, .totals, .note {
            margin-top: 20px;
            font-size: 14px;
        }
        .totals {
            float: right;
            width: 200px;
        }
        .totals table {
            width: 100%;
            border-collapse: collapse;
        }
        .totals th, .totals td {
            padding: 8px;
            border: 1px solid #ddd;
            text-align: right;
        }
        .totals th {
            background-color: #422146;
            color: white;
        }
        .note {
            margin-top: 50px;
            font-size: 12px;
            color: #555;
        }
    </style>
</head>
<body>

<div class="container">
    <!-- Header Section -->
    <div class="header">
        <h1>INVOICE</h1>
        <p>Invoice Number: #202409001</p>
        <p>Invoice Date: Apr 18, 2024</p>
    </div>

    <!-- Invoice and Recipient Info -->
    <div class="invoice-info">
        <div>
            <h2>FROM:</h2>
            <p>[Your Company Name]</p>
            <p>[Your Company Address]</p>
            <p>[Your City, Country]</p>
        </div>
        <div>
            <h2>BILL TO:</h2>
            <p>Jane Smith</p>
            <p>janesmith@email.com</p>
            <p>+91 - 1234567891</p>
            <p>123/225, x floor, B city</p>
            <p>Y Country - 532654</p>
            <p>33GHTAA0000A1Z6</p>
        </div>
    </div>

    <!-- Item Table -->
    <table class="table">
        <thead>
            <tr>
                <th>S.No</th>
                <th>Title</th>
                <th>Qty</th>
                <th>Price</th>
                <th>Total</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>01</td>
                <td>Banner Design</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
            <tr>
                <td>02</td>
                <td>Website designing</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
            <tr>
                <td>03</td>
                <td>API Integration work</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
            <tr>
                <td>04</td>
                <td>Website designing</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
            <tr>
                <td>05</td>
                <td>Site Updated</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
            <tr>
                <td>06</td>
                <td>Website designing</td>
                <td>01</td>
                <td>00.00</td>
                <td>00.00</td>
            </tr>
        </tbody>
    </table>

    <!-- Payment Info -->
    <div class="payment-info">
        <h2>PAYMENT INFO:</h2>
        <p>A/C Name : Holder Name Here</p>
        <p>A/C No : 11231546879</p>
        <p>IFS Code : ICICI1231215</p>
        <p>Pan No : Ghdng1234H</p>
        <p>GST No : 22AAAAA0000A1Z5</p>
    </div>

    <!-- Totals Section -->
    <div class="totals">
        <table>
            <tr>
                <th>Subtotal</th>
                <td>00.00</td>
            </tr>
            <tr>
                <th>Tax</th>
                <td>00.00</td>
            </tr>
            <tr>
                <th>Roundoff</th>
                <td>00.00</td>
            </tr>
            <tr>
                <th>Grand Total</th>
                <td>00.00</td>
            </tr>
        </table>
    </div>

    <!-- Note Section -->
    <div class="note">
        <p>NOTE:</p>
        <p>We declare that the invoice shows the actual price of the goods described and that all particulars are true and correct.</p>
        <p>*** CHEQUE Bounce Charges will be levied based on bank debits ***</p>
    </div>
</div>

</body>
</html>
```

This HTML document styles an invoice similar to your uploaded image. Adjust any details, such as company information and currency formatting, as needed. For a more polished design, you could add more advanced styling with CSS, or use a library like Bootstrap.
