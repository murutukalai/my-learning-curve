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
