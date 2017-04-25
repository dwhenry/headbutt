module Headbutt
  class Banner
    def self.print
      # Print logo and banner for development
      puts "\e[#{31}m"
      puts banner
      puts "\e[0m"
    end

    def self.banner
      <<-BANNER_END

                                    ~~~~
                                =~?~~~
,                             ++7I,I~
:::,                          ?I$DDZ?=
~::,:~:,                     ??7$DOZ7~
===~:,:~~                     ,ZDDMDI~
7?I???++::~~,                   ,DN8I~
NDD8$7I??=~:~=~:::         ~+7+~~DNNI~
  ,:?ODMMNNDO+~:~:+:,?~ ~=::$:=:.?M7~
          ~$ND8NO+=:::,=~.D+,:::,..$~
             ,IND8O+~+$,.,..=:+~=,++
               ,+NZNN8...,~?,,Z~+:+,+~
                 INM~..MM7~,,..+I=?M:~
    ~=~            =.~MMMD+~=+?~,~7M~
:?=+I~+++=?,      Z,,:+:M==+??+I?:NM:~
?++~~7III7I7I,    .:?I=?~~????+=$MD?~
+?$$=7$Z$8O7O..I7.+?I7??I?+I7II+.M=:
III77$ZZ8$7I78~I~~=+Z77$$77$7$.D=:
777Z$O8$7I7$$8?I+==Z=$ZZ7??=ZOMI,  __   __ _______ _______ ______  _______ __   __ _______ _______
7$ZZO:7I7II7$$D?+?77+==?+???:,     |  | |  |       |   _   |      ||  _    |  | |  |       |       |
7ZZ88O7?I7I77ZD:=??=~=?I7$:::,     |  |_|  |    ___|  |_|  |  _    | |_|   |  | |  |_     _|_     _|
778O$7?+?I7777Z=~:=?++77Z=:        |       |   |___|       | | |   |       |  |_|  | |   |   |   |
77887=OII7II$$ID,,~,:~=:$,         |       |    ___|       | |_|   |  _   ||       | |   |   |   |
ZDOOOO87?$ZIIO778D$+:,,.,,.?       |   _   |   |___|   _   |       | |_|   |       | |   |   |   |
8MO888DD+=Z?77.Z777?I??+?===++     |__| |__|_______|__| |__|______||_______|_______| |___|   |___|
8DDD8D8D7ZO~+~+,??IIIIII???++?+=   So I couldn't find a picture of a headbutt. but this is better right?
      BANNER_END
    end
  end
end
