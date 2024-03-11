pageextension 71748 "Phys. Inventory Journal" extends "Phys. Inventory Journal"
{
    layout
    {
        addafter("Qty. (Phys. Inventory)")
        {

            field(Leido; rec.Leido)
            {
                ToolTip = 'Read', comment = 'ESP="Leido"';
                ApplicationArea = all;
            }

        }
    }

    actions
    {
        addafter(CalculateInventory)
        {
            action(Resetear)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    CurrentJnlBatchName: Text;
                begin
                    CurrentJnlBatchName := Rec."Journal Batch Name";
                    Rec.Reset();
                    rec.SetRange(Leido, false);
                    rec.SetRange("Phys. Inventory", true);
                    rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
                    IF Rec.FindSet() then
                        repeat
                            rec.Validate("Qty. (Phys. Inventory)", 0);
                            rec.Modify();
                        until rec.Next() = 0;
                    Rec.Reset();
                end;
            }
            action(Completar)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    CurrentJnlBatchName: Text;
                begin
                    CurrentJnlBatchName := Rec."Journal Batch Name";
                    Rec.Reset();
                    rec.SetRange(Leido, false);
                    rec.SetRange("Phys. Inventory", true);
                    rec.SetRange("Journal Batch Name", CurrentJnlBatchName);
                    IF Rec.FindSet() then
                        repeat
                            rec.Validate("Qty. (Phys. Inventory)", rec."Qty. (Calculated)");
                            rec.Modify();
                        until rec.Next() = 0;
                    Rec.Reset();
                end;
            }

        }
    }

}