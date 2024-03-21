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
}