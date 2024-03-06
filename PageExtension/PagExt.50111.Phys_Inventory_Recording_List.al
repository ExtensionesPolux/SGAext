pageextension 50111 Phys_Inventory_Recording_List extends "Phys. Inventory Recording List"
{
    layout
    {
        addafter(Status)
        {
            field(App; App)
            {
                ApplicationArea = all;
                Editable = false;
            }
        }
    }
}