unit zuncomprfp;

{ uncompr.c -- decompress a memory buffer
  Copyright (C) 1995-1998 Jean-loup Gailly.

  Pascal tranlastion
  Copyright (C) 1998 by Jacques Nomssi Nzali
  For conditions of distribution and use, see copyright notice in readme.txt
}

interface

uses
  zbase, zinflate;

{ ===========================================================================
     Decompresses the source buffer into the destination buffer.  sourceLen is
   the byte length of the source buffer. Upon entry, destLen is the total
   size of the destination buffer, which must be large enough to hold the
   entire uncompressed data. (The size of the uncompressed data must have
   been saved previously by the compressor and transmitted to the decompressor
   by some mechanism outside the scope of this compression library.)
   Upon exit, destLen is the actual size of the compressed buffer.
     This function can be used to decompress a whole file at once if the
   input file is mmap'ed.

     uncompress returns Z_OK if success, Z_MEM_ERROR if there was not
   enough memory, Z_BUF_ERROR if there was not enough room in the output
   buffer, or Z_DATA_ERROR if the input data was corrupted.
}

function uncompress (dest : Pbyte;
                     var destLen : cardinal;
                     const source : array of byte;
                     sourceLen : cardinal) : integer;

function DecompressBuf(const InBuf: Pointer; InBytes: Integer;
  OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer):integer;

function decompress(const s:string):string;

implementation
const
Z_EOF = -1;         { same value as in STDIO.H }
{ gzip flag byte }

ASCII_FLAG  = $01; { bit 0 set: file probably ascii text }
HEAD_CRC    = $02; { bit 1 set: header CRC present }
EXTRA_FIELD = $04; { bit 2 set: extra field present }
ORIG_NAME   = $08; { bit 3 set: original file name present }
COMMENT     = $10; { bit 4 set: file comment present }
RESERVED    = $E0; { bits 5..7: reserved }

function DecompressBuf(const InBuf: Pointer; InBytes: Integer;
  OutEstimate: Integer; out OutBuf: Pointer; out OutBytes: Integer):integer;
var
  strm: z_stream;
  P: Pointer;
  BufInc: Integer;
  err,flags,c : integer;
  len,ptr: word;

  function DCheckLoop(code: Integer): boolean;

  begin
  err:=code;
  result:= (code >=0) and (code<>Z_STREAM_END);
  end;

begin
  FillChar(strm, sizeof(strm), 0);
  BufInc := (InBytes + 255) and not 255;
  if OutEstimate = 0 then
    OutBytes := BufInc
  else
    OutBytes := OutEstimate;
  GetMem(OutBuf, OutBytes);
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := OutBytes;
    if (pchar(Inbuf)[0]=#$1F) and (pchar(Inbuf)[1]=#$8B) then
      begin
      flags:=byte(pchar(Inbuf)[3]);
      if (byte(pchar(Inbuf)[2]) <> Z_DEFLATED) or ((flags and RESERVED) <> 0) then
        err := Z_DATA_ERROR
      else
        begin
        ptr:=10; { Discard time, xflags and OS code }
        if ((flags and EXTRA_FIELD) <> 0) then begin { skip the extra field }
          len := word(byte(pchar(Inbuf)[ptr])) + (word(byte(pchar(Inbuf)[ptr+1])) shr 8);
          { len is garbage if EOF but the loop below will quit anyway }
          ptr:=ptr+2;
          while (len <> 0)  do
            begin
            Dec(len);
            ptr:=ptr+1;
            if byte(pchar(Inbuf)[ptr-1]) = Z_EOF  then break;
            end;
        end;
        if ((flags and ORIG_NAME) <> 0) then begin { skip the original file name }
          repeat
            c := byte(pchar(Inbuf)[ptr]);
            ptr:=ptr+1;
          until (c = 0) or (c = Z_EOF);
        end;
        if ((flags and COMMENT) <> 0) then begin { skip the .gz file comment }
          repeat
            c := byte(pchar(Inbuf)[ptr]);
            ptr:=ptr+1;
          until (c = 0) or (c = Z_EOF);
        end;
        if ((flags and HEAD_CRC) <> 0) then begin { skip the header crc }
          ptr:=ptr+2;
        end;
        strm.next_in := pByte(PtrUInt(strm.next_in)+ptr);
        strm.avail_in := strm.avail_in-ptr;
        err := inflateInit2_(strm, -MAX_WBITS, ZLIB_VERSION, sizeof(strm));
        end;
      end
    else
      err := inflateInit(strm);
    if (err <> Z_OK) then
    begin
      DecompressBuf := err;
      exit;
    end;
    try
      while DCheckLoop(inflate(strm, Z_SYNC_FLUSH)) do
      begin
        P := OutBuf;
        Inc(OutBytes, BufInc);
        ReallocMem(OutBuf, OutBytes);
        strm.next_out := PByte(PtrUInt(OutBuf) + (PtrUInt(strm.next_out) - PtrUInt(P)));
        strm.avail_out := BufInc;
      end;
    finally
      if (err=Z_STREAM_END) then
        err:=inflateEnd(strm)
      else
        inflateEnd(strm);
    end;
    ReallocMem(OutBuf, strm.total_out);
    OutBytes := strm.total_out;
    DecompressBuf := err;
  except
    FreeMem(OutBuf);
    err:=Z_BUF_ERROR;
  end;
DecompressBuf := err;
end;



function uncompress (dest : Pbyte;
                     var destLen : cardinal;
                     const source : array of byte;
                     sourceLen : cardinal) : integer;
var
  stream : z_stream;
  err : integer;
begin
  stream.next_in := Pbyte(@source);
  stream.avail_in := cardinal(sourceLen);
  { Check for source > 64K on 16-bit machine: }
  if (cardinal(stream.avail_in) <> sourceLen) then
  begin
    uncompress := Z_BUF_ERROR;
    exit;
  end;

  stream.next_out := dest;
  stream.avail_out := cardinal(destLen);
  if (cardinal(stream.avail_out) <> destLen) then
  begin
    uncompress := Z_BUF_ERROR;
    exit;
  end;

  err := inflateInit(stream);
  if (err <> Z_OK) then
  begin
    uncompress := err;
    exit;
  end;

  err := inflate(stream, Z_FINISH);
  if (err <> Z_STREAM_END) then
  begin
    inflateEnd(stream);
    if err = Z_OK then
      uncompress := Z_BUF_ERROR
    else
      uncompress := err;
    exit;
  end;
  destLen := stream.total_out;

  err := inflateEnd(stream);
  uncompress := err;
end;

function decompress(const s:string):string;
var
  OutBuf: Pointer;
  OutBytes: Integer;

begin
  result:='';
  DecompressBuf(@s[1],length(s),0,OutBuf,OutBytes);
  if Outbytes>0 then
    begin
    setlength(result,OutBytes);
    move(OutBuf^,result[1],OutBytes);
    end;
  FreeMem(OutBuf);
end;


end.
