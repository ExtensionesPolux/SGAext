pageextension 71747 Company_Info_SGA extends "Company Information"
{
    layout
    {
        addafter("User Experience")
        {
            group(SGA)
            {
                Caption = 'SGA';

                grid(Grid2)
                {
                    GridLayout = Columns;

                    field("License Polux SGA"; rec."License Polux SGA")
                    {
                        ApplicationArea = all;
                    }
                    field("URL API"; rec."URL API")
                    {
                        ApplicationArea = all;
                    }
                    field("Azure Code"; rec."Azure Code")
                    {
                        ApplicationArea = all;
                    }
                    field("Vector AES"; rec."Vector AES")
                    {
                        ApplicationArea = all;
                        ExtendedDatatype = Masked;
                    }
                }
            }
        }
    }

    actions
    {
        addafter("P&ayments")
        {
            action(SGA_Test)
            {
                Caption = 'Test URL SGA';
                Image = TestFile;
                ApplicationArea = all;
                Promoted = true;

                trigger OnAction()
                var
                    LicenseMgt: Codeunit "SGA License Management";
                begin
                    LicenseMgt.Test();
                end;
            }
        }
    }

}