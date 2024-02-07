page 50100 PageReservas
{
    Caption = 'Reservas';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Reservation Entry";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;

                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;

                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;

                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;

                }
                field("Source Subtype"; Rec."Source Subtype")
                {
                    ApplicationArea = All;

                }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction();
                begin

                end;
            }
        }
    }
}