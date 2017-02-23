{ lib }:
with lib;
{
  foo = mkOption {
    default = 1;
    type = types.int;
    description = "Some thing";
  };
}
