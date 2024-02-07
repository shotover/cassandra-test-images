# Docker Cassandra test images

Cassandra images with drastically faster startup times for use in integration tests.
Do not use them in production.

The faster startup time is achieved by hardcoding the tokens for each node:

* If `CASSANDRA_SEEDS` is specified (clustered) then you must provide your own set of tokens via `CASSANDRA_INITIAL_TOKENS`, you can copy the tokens used in the sample below, they were taken from a default configuration `library/cassandra` cluster of 3 nodes.
* If `CASSANDRA_SEEDS` is unspecified (non-clustered) there is no need to provide your own tokens.

## Single Usage

```yaml
version: "3.3"
services:
  cassandra-one:
    image: shotover/cassandra-test:4.0.6-r1
    ports:
      - "9042:9042"
    environment:
      MAX_HEAP_SIZE: "400M"
      MIN_HEAP_SIZE: "400M"
      HEAP_NEWSIZE: "48M"
    volumes:
        # tmpfs is a lot faster but if you need to test nodes being shutdown and brought up again use a `volume` instead of `tmpfs`
      - type: tmpfs
        target: /var/lib/cassandra
      - type: bind
        source: "certs/keystore.p12"
        # Optionally bind a keystore to this path in order to enable TLS
        target: "/etc/cassandra/certs/keystore.p12"
```

When `CASSANDRA_SEEDS` is not present the instance will always have a data center of `datacenter1` and a rack of `rack1`.
These values are not configurable as cassandra hardcodes them when using the fastest start up process.

## Cluster Usage

```yaml
version: "3.3"
networks:
  cluster_subnet:
    name: cluster_subnet
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.16.1.0/24
          gateway: 172.16.1.1

services:
  cassandra-one:
    image: &image shotover/cassandra-test:4.0.6-r1
    networks:
      cluster_subnet:
        ipv4_address: 172.16.1.2
    environment: &environment
      CASSANDRA_SEEDS: "cassandra-one,cassandra-two,cassandra-three"
      CASSANDRA_CLUSTER_NAME: TestCluster
      CASSANDRA_DC: dc1
      CASSANDRA_RACK: rack1
      CASSANDRA_ENDPOINT_SNITCH: GossipingPropertyFileSnitch
      CASSANDRA_INITIAL_TOKENS: -1070335827948913273,-1262780231953846581,-1372586501761710870,-1531116802331162256,-163362083013332509,-1695623576168766293,-1804498187836887715,-1946106156776485520,-2056453585786233579,-2215276878049099070,-2343278388525192983,-2548968207073589272,-2718848566609997839,-2810829291456476999,-2960742485753654915,-300136287927625825,-3066171811868387352,-3212944421347252253,-3379856628404362106,-3482091781751694282,-3620468823413622084,-3714264728468904973,-3857538363369767184,-3992822749261253815,-4079256680142421758,-4220202103792919330,-4367898183274149976,-4551025118927524312,-471290094307005363,-4742836653234322740,-4864732456348559975,-5060737053316205324,-5207857922059935586,-52840734170572300,-5392608158602524302,-5591707161765757347,-5719371107113340348,-574774067866083148,-5905113700807367081,-6064244949291727065,-6176664591963928272,-6332078773725710211,-6432427113055333695,-6586359736274194228,-6743512440489798680,-6845093364625549830,-6996410811499579341,-713444869718811462,-7168884701115756243,-7274128064287226174,-7446523579358567501,-7559015074080672349,-7726720852570152935,-7863620627939574516,-7953250106433078478,-8092452711734517630,-8199788990029145821,-8373699889885432815,-8544039658474896486,-859630544771061355,-8759221946503374753,-8919633668743362629,-9019110376775037498,-9173846866235956778,103714383615439684,1098226704217661717,1227871255888263829,1316739704183204187,1491001625227011179,1645946234495158049,1754240148183667031,1905451572012652200,199201432712497741,2016307737474393503,2177599511665263375,2341796809284406230,2450674246426799652,2623990001964297679,2804477461124776252,2937402454393518499,3095961017485413027,3205311148009103264,3421119517345855347,3612339999845077896,362311011506768076,3751193928058060440,3965582965057198705,4105489420026468015,4204758006957390723,4388483760424390846,4576911512875681446,4691569685096124520,4830253606480231274,4921495432287268245,503658101740669817,5080624335143342111,5184264706352018320,5341965577439578406,5472653858019210550,5563061523591362180,5704213330324189109,5856744011612998895,5978488312938289484,617606604743448883,6176989578371539613,6325548347569741056,6457505413000155610,6546847651267682190,6742276931944292552,6886150343510243611,7019379198083928892,7116146590348156274,7283195764438888312,7457031967979733254,7597511608635332781,769362778173404078,7805206394409370938,7971757036117465495,8107365759249009360,8204193150302005303,8330270968875552899,8423008301510322314,8575657061151446857,8719671759152143907,8828129486053943115,8979301877610065508,9147701452061713801,953293656790161474
      MAX_HEAP_SIZE: "400M"
      MIN_HEAP_SIZE: "400M"
      HEAP_NEWSIZE: "48M"
    volumes:
      &volumes
        # tmpfs is a lot faster but if you need to test nodes being shutdown and brought up again use a `volume` instead of `tmpfs`
      - type: tmpfs
        target: /var/lib/cassandra
      - type: bind
        source: "certs/keystore.p12"
        # Optionally bind a keystore to this path in order to enable TLS
        target: "/etc/cassandra/certs/keystore.p12"
    command: &command cassandra -f -Dcassandra.initial_token="$$CASSANDRA_INITIAL_TOKENS" -Dcassandra.native_transport_port=9044

  cassandra-two:
    image: *image
    networks:
      cluster_subnet:
        ipv4_address: 172.16.1.3
    environment:
      <<: *environment
      CASSANDRA_INITIAL_TOKENS: -1040723580916052090,-1171411861495684236,-1329112732583244321,-1432753103791920530,-1591882006647994397,-1683123832455031366,-1821807753839138121,-187829091365521586,-1936465926059581195,-2124893678510871797,-2308619431977871918,-2407888018908794625,-2547794473878063936,-2762183510877202201,-2901037439090184745,-3092257921589407295,-3308066290926159377,-336387860563723028,-3417416421449849613,-3575974984541744143,-3708899977810486389,-3889387436970964963,-4062703192508462990,-4171580629650856412,-4335777927269999269,-4497069701460869140,-4607925866922610442,-4759137290751595611,-4867431204440104591,-5022375813708251462,-5196637734752058454,-5285506183046998811,-534889125996973159,-5415150734717600926,-5560083782145101168,-55872025935107032,-5744014660761858564,-5895770834191813759,-6009719337194592824,-6151066427428494567,-6314176006222764901,-6409663055319822958,-6566218173105834944,-656633427322263746,-6676739521948595153,-6813513726862888469,-6984667533242268007,-7088151506801345793,-7226822308654074107,-7373007983706324000,-7583713266884175918,-7776157670889109226,-7885963940696973515,-8044494241266424901,-809164108611073533,-8209001015104028938,-8317875626772150360,-8459483595711748165,-8569831024721496224,-8728654316984361715,-8856655827460455628,-9062345646008851917,-950315915343900461,1084134169700070137,1291828955474108294,1458379597182202851,1593988320313746716,1690815711366742659,1816893529940290255,1909630862575059670,2062279622216184213,2206294320216881263,228899493009029909,2314752047118680471,2465924438674802864,2634324013126451157,2759519768538332193,2914256257999251471,3013732966030926341,3174144688270914218,33470212332419547,3389326976299392483,3559666744888856155,372772904574980968,3733577644745143148,3840913923039771341,3980116528341210490,4069746006834714453,4206645782204136035,4374351560693616620,4486843055415721469,4659238570487062795,4764481933658532727,4936955823274709630,506001759148666249,5088273270148739139,5189854194284490289,5347006898500094741,5500939521718955273,5601287861048578758,5756702042810360696,5869121685482561904,602769151412893631,6028252933966921889,6213995527660948621,6341659473008531622,6540758476171764667,6725508712714353383,6872629581458083647,7068634178425728993,7190529981539966228,7382341515846764656,7565468451500138991,769818325503625668,7713164530981369639,7854109954631867209,7940543885513035153,8075828271404521784,8219101906305383995,8312897811360666885,8451274853022594685,8553510006369926862,8720422213427036715,8867194822905901615,8972624149020634054,9122537343317811969,9214518068164291130,943654529044470610
    volumes: *volumes
    command: *command

  cassandra-three:
    image: *image
    networks:
      cluster_subnet:
        ipv4_address: 172.16.1.4
    environment:
      <<: *environment
      CASSANDRA_INITIAL_TOKENS: -1118567412469902436,-1313996693146512799,-1403338931414039378,-1535295996844453933,-1683854766042655376,-1882356031475905507,-2004100332801196094,-2156631014090005881,-2297782820822832809,-2388190486394984438,-2518878766974616584,-263332735778862210,-2676579638062176669,-2780220009270852878,-2939348912126926745,-3030590737933963714,-3169274659318070469,-3283932831538513543,-3472360583989804145,-3656086337456804266,-3755354924387726973,-3895261379356996284,-403812376434461735,-4109650416356134549,-4248504344569117093,-4439724827068339643,-4655533196405091725,-4764883326928781961,-4923441890020676491,-5056366883289418737,-5236854342449897311,-5410170097987395338,-5519047535129788760,-55637950004824052,-5683244832748931617,-577648579975306678,-5844536606939801488,-5955392772401542790,-6106604196230527959,-6214898109919036939,-6369842719187183810,-6544104640230990802,-6632973088525931159,-6762617640196533274,-6907550687624033516,-7091481566240790912,-7243237739670746107,-7357186242673525172,-744697754066038715,-7498533332907426915,-7661642911701697249,-7757129960798755306,-7913685078584767292,-8024206427427527501,-8160980632341820817,-8332134438721200355,-841465146330266096,-8435618412280278141,-8574289214133006455,-8720474889185256349,-8931180172363108268,-9123624576368041577,-974694000903951379,110912691703270503,1118457533195870516,1286857107647518809,1412052863059399845,1566789352520319123,1666266060551993993,1826677782791981870,2041860070820460135,2212199839409923807,2386110739266210800,246521414834814368,2493447017560838993,2632649622862278142,2722279101355782105,2859178876725203687,3026884655214684272,3139376149936789121,3311771665008130447,3417015028179600379,343348805887810311,3589488917795777282,3740806364669806791,3842387288805557941,3999539993021162393,4153472616240022925,4253820955569646410,4409235137331428348,4521654780003629556,4680786028487989541,469426624461357907,4866528622182016273,4994192567529599274,5193291570692832319,5378041807235421035,5525162675979151299,562163957096127322,5721167272946796645,5843063076061033880,6034874610367832308,6218001546021206643,6365697625502437291,6506643049152934861,6593076980034102805,6728361365925589436,6871635000826451647,6965430905881734537,7103807947543662337,714812716737251865,7206043100890994514,7372955307948104367,7519727917426969267,7625157243541701706,7775070437838879621,7867051162685358782,8036931522221767350,8242621340770163636,8370622851246257550,8529446143509123040,858827414737948915,8639793572518871100,8781401541458468904,8890276153126590327,9054782926964194365,9213313227533645749,967285141639748123
    volumes: *volumes
    command: *command
```
