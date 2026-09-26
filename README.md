# Travel checklist

One spreadsheet of camping and travel gear, and a script that prints a two-column checklist for a single trip type.

## The spreadsheet

`packing-list.ods` lists each item with its category and notes, and a column for each trip type: Weekend, Car camping, Overlanding, and Backpacking. An `x` in a column puts the item on that trip's checklist. Edit it in LibreOffice Calc; the header row stays in view as you scroll, and the column filters show one trip's list at a time.

To add a trip type, add a column after Backpacking. The script picks it up by its header.

## Printing a checklist

Requires [LibreOffice](https://www.libreoffice.org/) and [Typst](https://typst.app/).

```
./checklist.sh backpacking        # checklist-backpacking.pdf
./checklist.sh car ~/car.pdf      # custom output path
./checklist.sh all                # one PDF per trip type
```

The trip name matches the start of a column header, ignoring case. The script exports the spreadsheet to CSV and `checklist.typ` lays out the checked items by category, with a box to tick beside each one. Adjust the page size, font, or spacing in `checklist.typ`.
