query 71740 "Lot Numbers by Location 2"
{
    Caption = 'Lot Numbers by Bin';
    OrderBy = Ascending(Item_No);

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(Location_Code; "Location Code")
            {
            }
            column(Item_No; "Item No.")
            {
            }
            column(Variant_Code; "Variant Code")
            {
            }
            column(Lot_No; "Lot No.")
            {
            }
            column(Serial_No; "Serial No.")
            {
            }
            column(Package_No; "Package No.")
            {
            }
            column(Unit_of_Measure_Code; "Unit of Measure Code")
            {
            }
            column(Sum_Qty; Quantity)
            {
                ColumnFilter = Sum_Qty = FILTER(<> 0);
                Method = Sum;
            }
        }
    }
}

