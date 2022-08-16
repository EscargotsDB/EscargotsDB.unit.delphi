unit EscargotsDB;

interface

uses
  System.SysUtils,IdHTTP,System.JSON,System.Classes,Vcl.Dialogs,eDbQuery;

  type TeDB = class
  private
    var
    JsonToSend:tStringStream;
    cont:Integer;
    Fport: string;
    Fhost: string;
    Fdebug: Boolean;
    procedure Sethost(const Value: string);
    procedure Setport(const Value: string);
    procedure Setdebug(const Value: Boolean);
    function TrocaCaracterEspecial(aTexto : string; aLimExt : boolean) : string;
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    property host:string read Fhost write Sethost;
    property port:string read Fport write Setport;
    property debug:Boolean read Fdebug write Setdebug;
    function _set_(collection,key:string):boolean;
    function _get_(collection,key:string):TJSONObject;
    function _del_(collection,key:string):boolean;
    function get_list(listName,collection:string):TJSONArray;
    function send_list(listName,collection,key:string):Boolean;
    function addData(property_,value:string):Boolean;
  published
    { published declarations }
  end;


implementation

{ TeDB }

function TeDB.addData(property_, value:string): Boolean;
begin
if Assigned(JsonToSend) then begin
    cont := cont + 1;
  With JsonToSend do
   Begin
      if Length(value) < 1 then begin
        value := 'nil';
      end;
      JsonToSend.WriteString(','+TrocaCaracterEspecial(property_,True).QuotedString('"')+':'+TrocaCaracterEspecial(value,True).QuotedString('"'));
   end
end else begin
 JsonToSend := TStringStream.Create();
 cont := 1;
 JsonToSend.WriteString('{');
 JsonToSend.WriteString(TrocaCaracterEspecial(property_,True).QuotedString('"')+':'+TrocaCaracterEspecial(value,True).QuotedString('"'));
end;
Result := True;
end;


function TeDB.get_list(listName, collection: string): TJSONArray;
var
lHTTP : TIdHTTP;
objeto: TJSONArray;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/get/list?name='+listName+'&collection='+collection);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONArray;

       Result := objeto;

     finally
       lHTTP.Free;
     end;

end;


function TeDB.send_list(listName, collection, key: string): Boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin

     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/send/list?name='+listName+'&collection='+collection+'&key='+key);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Result := False;
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

procedure TeDB.Setdebug(const Value: Boolean);
begin
  Fdebug := Value;
end;

procedure TeDB.Sethost(const Value: string);
begin
  Fhost := Value;
end;

procedure TeDB.Setport(const Value: string);
begin
  Fport := Value;
end;

function TeDB.TrocaCaracterEspecial(aTexto: string; aLimExt: boolean): string;
const
  //Lista de caracteres especiais
  xCarEsp: array[1..38] of String = ('�', '�', '�', '�', '�','�', '�', '�', '�', '�',
                                     '�', '�','�', '�','�', '�','�', '�',
                                     '�', '�', '�','�', '�','�', '�', '�', '�', '�',
                                     '�', '�', '�','�','�', '�','�','�','�','�');
  //Lista de caracteres para troca
  xCarTro: array[1..38] of String = ('a', 'a', 'a', 'a', 'a','A', 'A', 'A', 'A', 'A',
                                     'e', 'e','E', 'E','i', 'i','I', 'I',
                                     'o', 'o', 'o','o', 'o','O', 'O', 'O', 'O', 'O',
                                     'u', 'u', 'u','u','u', 'u','c','C','n', 'N');
  //Lista de Caracteres Extras
  xCarExt: array[1..48] of string = ('<','>','!','@','#','$','%','�','&','*',
                                     '(',')','+','=','{','}','[',']','?',
                                     ';',':','|','*','"','~','^','�','`',
                                     '�','�','�','�','�','�','�','�','�','�',
                                     '�','�','�','�','�','�','�','�','"','�');
var
  xTexto : string;
  i : Integer;
begin
   xTexto := aTexto;
   for i:=1 to 38 do
     xTexto := StringReplace(xTexto, xCarEsp[i], xCarTro[i], [rfreplaceall]);
   //De acordo com o par�metro aLimExt, elimina caracteres extras.
   if (aLimExt) then
     for i:=1 to 48 do
       xTexto := StringReplace(xTexto, xCarExt[i], '', [rfreplaceall]);
   Result := xTexto;
end;

function TeDB._del_(collection, key: string): boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/del?key='+key+'&collection='+collection);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

function TeDB._get_(collection, key: string): TJSONObject;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
begin
     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.get('http://'+Fhost+':'+Fport+'/get?collection='+collection+'&key='+key);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := objeto;
       end else begin
         Result := objeto;
       end;

     finally
       lHTTP.Free;
     end;
end;

function TeDB._set_(collection,key:string): boolean;
var
lHTTP : TIdHTTP;
objeto: TJSONObject;
_result:string;
json:string;
payload: TStringStream;
begin

     if cont < 1 then begin
       ShowMessage('ERROR No value to set');
       Result := False;
       Exit;
     end;

     JsonToSend.WriteString('}');
     payload := JsonToSend;

     lHTTP := TIdHTTP.Create(nil);
     try
       lHTTP.Request.ContentType := 'application/json';
       lHTTP.Request.CharSet := 'UTF-8';
       //Exit;
       try
       _result := lHTTP.post('http://'+Fhost+':'+Fport+'/set?collection='+collection+'&key='+key,payload);
       except
         on e: exception do
         begin
          ShowMessage('ERRO ['+e.Message+'] ao tentar conectar ao servidor.');
          Result := False;
          Exit;
         end;
       end;
       json :=  _result;
       objeto := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(json),0) as TJSONObject;

       if objeto.GetValue('result').Value = 'True' then
       begin
         Result := True;
       end else begin
         Result := False;
       end;

     finally
       lHTTP.Free;
     end;

end;

end.
