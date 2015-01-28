package toplevel;

class EscapeStringSpec {
  public static function esc(str) {
    return EscapeString.call(str);
  }
  public static function describe(d:spaceCadet.Description) {
    d.describe("EscapeString", function(d) {
      d.it("hex escapes 0-6", function(a) {
        a.eq("\\x00\\x01\\x02\\x03\\x04\\x05\\x06",
         esc("\x00\x01\x02\x03\x04\x05\x06"));
      });
      d.it("uses common escaped chars for 7-13", function(a) {
        a.eq("\\a\\b\\t\\n\\v\\f\\r",
         esc("\x07\x08\x09\x0A\x0B\x0C\x0D"));
      });
      d.it("hex escapes 14-26", function(a) {
        a.eq("\\x0E\\x0F\\x10\\x11\\x12\\x13\\x14\\x15\\x16\\x17\\x18\\x19\\x1A",
         esc("\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A"));
      });
      d.it("uses \\e for 27", function(a) {
        a.eq("\\e",
         esc("\x1B"));
      });
      d.it("hex escapes 28-31", function(a) {
        a.eq("\\x1C\\x1D\\x1E\\x1F",
         esc("\x1C\x1D\x1E\x1F"));
      });
      d.it("uses common symbols for 32-47", function(a) {
        a.eq(" !\"#$%&'()*+,-./",
         esc("\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F"));
      });
      d.it("uses digits for 48-57", function(a) {
        a.eq("0123456789",
         esc("\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39"));
      });
      d.it("uses common symbols for 58-64", function(a) {
        a.eq(":;<=>?@",
         esc("\x3A\x3B\x3C\x3D\x3E\x3F\x40"));
      });
      d.it("uses uppercase letters for 65-90", function(a) {
        a.eq("ABCDEFGHIJKLMNOPQRSTUVWXYZ",
         esc("\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A"));
      });
      d.it("uses common symbols for 91-96", function(a) {
        a.eq("[\\]^_`",
         esc("\x5B\x5C\x5D\x5E\x5F\x60"));
      });
      d.it("uses lowercase letters for 97-122", function(a) {
        a.eq("abcdefghijklmnopqrstuvwxyz",
         esc("\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A"));
      });
      d.it("uses common symbols for 123-126", function(a) {
        a.eq("{|}~",
         esc("\x7B\x7C\x7D\x7E"));
      });
      d.it("hex escapes 127", function(a) {
        a.eq("\\x7F",
         esc("\x7F"));
      });
      d.it("does not escape unicode characters", function(a) {
        a.eq("¡™£", esc("¡™£"));
      });
    });
  }
}

