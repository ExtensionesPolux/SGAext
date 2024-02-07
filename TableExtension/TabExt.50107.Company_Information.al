tableextension 50107 Company_Information_SGA extends "Company Information"
{
    fields
    {
        field(50100; "License Polux SGA"; code[100])
        {
            Caption = 'Licencia SGA Polux';
        }
        field(50101; "URL API"; text[200])
        {
            Caption = 'URL API';
        }
        field(50102; "Azure Code"; text[100])
        {
            Caption = 'Azure Code';
        }
        field(50103; "Vector AES"; text[16])
        {
            Caption = 'Vector Encriptación AES';
        }
    }

}