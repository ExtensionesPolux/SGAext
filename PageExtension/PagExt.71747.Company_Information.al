pageextension 71747 Company_Info_SGA extends "Company Information"
{
    layout
    {
        addafter("User Experience")
        {
            group(SGA)
            {
                Caption = 'AURA-SGA';


                field("License BC"; rec."License BC")
                {
                    ApplicationArea = all;
                }

                field("License Aura-SGA"; rec."License Aura-SGA")
                {
                    ApplicationArea = all;
                    MultiLine = True;
                }
                field("URL API"; rec."URL API")
                {
                    ApplicationArea = all;
                    MultiLine = True;
                }
                field("Azure Code"; rec."Azure Code")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                    MultiLine = True;
                }
                field("Vector AES"; rec."Vector AES")
                {
                    ApplicationArea = all;
                    ExtendedDatatype = Masked;
                    MultiLine = True;
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