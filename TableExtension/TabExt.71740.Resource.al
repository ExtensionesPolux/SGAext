tableextension 71740 Resource extends Resource
{
    fields
    {

        field(71740; Pin; code[10])
        {
            Caption = 'Pin to access', comment = 'ESP="Pin de acceso"';
            trigger OnValidate()
            var
                lblErrorLong: Label 'The pin must have at least 4 characters', Comment = 'ESP=El pin ha de tener al menos 4 carácteres';
            begin
                IF strlen(Pin) < 4 then error(lblErrorLong);
            end;
        }
        field(71741; "Permite Copiar"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Copy Allow', Comment = 'ESP=Permitir Copiar';
        }
        field(71742; "Permite Regularizar"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allows regularization', Comment = 'ESP=Permitir regularizar';
        }

        field(71743; "Ver cantidad inventario"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'View inventory quantity', Comment = 'ESP=Mostrar Cantidad inventario';
        }

        field(71744; "Permite cambiar picking"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Allows changing picking', Comment = 'ESP=Permitir cambiar Picking';
        }
    }

}