<packet-view-custom-value>
  <script type="babel">
    import riot from 'riot';
    this.on('mount', () => {
      if (opts.tag != null) {
        riot.mount(this.root, opts.tag, {value: opts.val});
      }
    });
  </script>
</packet-view-custom-value>

<packet-view-boolean-value>
  <i class="fa fa-check-square-o" if={ opts.val }></i>
  <i class="fa fa-square-o" if={ !opts.val }></i>
</packet-view-boolean-value>

<packet-view-buffer-value>
  <i>{ opts.val.length } bytes</i>
</packet-view-buffer-value>

<packet-view-stream-value>
  <i>{ opts.val.length } bytes</i>
</packet-view-stream-value>

<packet-view-integer-value>
  <i if={ base==2 } oncontextmenu={ context }>
    <i class="base">0b</i>{ opts.val.toString(2) }</i>
  <i if={ base==8 } oncontextmenu={ context }>
    <i class="base">0</i>{ opts.val.toString(8) }</i>
  <i if={ base==10 } oncontextmenu={ context }>{ opts.val.toString(10) }</i>
  <i if={ base==16 } oncontextmenu={ context }>
    <i class="base">0x</i>{ opts.val.toString(16) }</i>
  <script type="babel">
    import {remote} from 'electron';
    import {Menu} from 'dripcap';
    this.base = 10;

    this.context = e => {
      Menu.popup('packet-view:numeric-value-menu', this, remote.getCurrentWindow());
      e.stopPropagation();
    };
  </script>
</packet-view-integer-value>

<packet-view-string-value>
  <i></i>
  <script type="babel">
    import $ from 'jquery';

    this.on('update', () => {
      if (this.opts.val != null) {
        this.root.innerHTML = $('<div/>').text(this.opts.val.toString()).html();
      }
    });
  </script>
</packet-view-string-value>

<packet-view-item>
<li>
  <p class="label list-item" onclick={ toggle } range={ opts.field.data.start + '-' + opts.field.data.end } oncontextmenu={ context } onmouseover={ fieldRange } onmouseout={ rangeOut }>
    <i class="fa fa-circle-o" show={ !opts.field.fields }></i>
    <i class="fa fa-arrow-circle-right" show={ opts.field.fields && !show }></i>
    <i class="fa fa-arrow-circle-down" show={ opts.field.fields && show }></i>
    <a class="text-label">{ opts.field.name }:</a>
    <packet-view-boolean-value if={ type=='boolean' } val={ val }></packet-view-boolean-value>
    <packet-view-integer-value if={ type=='integer' } val={ val }></packet-view-integer-value>
    <packet-view-string-value if={ type=='string' } val={ val }></packet-view-string-value>
    <packet-view-buffer-value if={ type=='buffer' } val={ val }></packet-view-buffer-value>
    <packet-view-stream-value if={ type=='stream' } val={ val }></packet-view-stream-value>
    <packet-view-custom-value if={ type=='custom' } tag={ tag } val={ val }></packet-view-custom-value>
  </p>
  <ul show={ opts.field.fields && show }>
    <packet-view-item each={ f in opts.field.fields } layer={ opts.layer } field={ f }></packet-view-item>
  </ul>
</li>

<script type="babel">
  import {remote} from 'electron';
  import {Menu} from 'dripcap';
  import BufferStream from 'goldfilter/stream';
  this.show = false;

  this.toggle = e => {
    if (opts.field.fields != null) {
      this.show = !this.show;
    }
    e.stopPropagation();
  };

  this.rangeOut = () => this.parent.rangeOut();

  this.fieldRange = e => {
    this.parent.fieldRange(e);
  };

  this.context = e => {
    if (window.getSelection().toString().length > 0) {
      Menu.popup('packet-view:context-menu', this, remote.getCurrentWindow());
      e.stopPropagation();
    }
  };

  this.on('update', () => {
    this.layer = opts.layer;

    this.val = (opts.field.value != null)
      ? opts.field.value
      : this.layer.attrs[opts.field.attr];

    return this.type = (opts.field.tag != null)
      ? (this.tag = opts.field.tag, 'custom')
      : typeof this.val === 'boolean'
        ? 'boolean'
        : Number.isInteger(this.val)
          ? 'integer'
          : Buffer.isBuffer(this.val)
            ? 'buffer'
            : BufferStream.isStream(this.val)
              ? 'stream'
                : 'string';
  });
</script>

<style type="text/less" scoped>
  :scope {
    -webkit-user-select: auto;
  }
</style>

</packet-view-item>

<packet-view-layer>
<p class="layer-name list-item" oncontextmenu={ layerContext } onclick={ toggleLayer } onmouseover={ layerRange } onmouseout={ rangeOut }>
  <i class="fa fa-arrow-circle-right" show={ !visible }></i>
  <i class="fa fa-arrow-circle-down" show={ visible }></i>
  { layer.name }
  <i class="text-summary">{ layer.summary }</i>
</p>
<ul show={ visible }>
  <packet-view-item each={ f in layer.fields } layer={ layer } field={ f }></packet-view-item>
  <li if={ layer.error }>
    <a class="text-label">Error:</a>
    { layer.error }
  </li>
</ul>
<packet-view-layer each={ ns in rootKeys } layer={ rootLayers[ns] }></packet-view-layer>

<script type="babel">
  import {remote} from 'electron';
  import {Menu} from 'dripcap';
  this.visible = true;

  this.on('update', () => {
    this.layer = opts.layer;
    this.rootKeys = [];
    if (this.layer.layers != null) {
      this.rootLayers = this.layer.layers;
      this.rootKeys = Object.keys(this.rootLayers);
    }
  });

  this.layerContext = e => {
    this.clickedLayerNamespace = e.item.ns;
    Menu.popup('packet-view:layer-menu', this, remote.getCurrentWindow());
    e.stopPropagation();
  };

  this.rangeOut = () => this.parent.rangeOut();

  this.fieldRange = e => this.parent.fieldRange(e);

  this.layerRange = e => this.parent.layerRange(e);

  this.toggleLayer = e => {
    this.visible = !this.visible;
    e.stopPropagation();
  };
</script>

</packet-view-layer>

<packet-view>

<div if={ packet }>
  <ul>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Timestamp:
      </a>
      <i>{ packet.timestamp }</i>
    </li>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Captured Length:
      </a>
      <i>{ packet.payload.length }</i>
    </li>
    <li>
      <i class="fa fa-circle-o"></i>
      <a class="text-label">
        Actual Length:
      </a>
      <i>{ packet.len }</i>
    </li>
  <li if={ packet.caplen < packet.length }> <i class="fa fa-exclamation-circle text-warn"> This packet has been truncated.</i> </li> </ul> <packet-view-layer each={ ns in rootKeys } layer={ rootLayers[ns] }></packet-view-layer>
</div>

<script type="babel">
  import {remote} from 'electron';
  import {PubSub} from 'dripcap';

  this.set = pkt => {
    this.packet = pkt;
    if (pkt != null) {
      this.rootLayers = this.packet.layers;
      this.rootKeys = Object.keys(this.rootLayers);
    }
  };

  this.fieldRange = e => {
    let fieldRange = e.currentTarget.getAttribute('range').split('-');
    let range = [
      parseInt(fieldRange[0]),
      parseInt(fieldRange[1])
    ];
    PubSub.pub('packet-view:range', range);
  };

  this.layerRange = e => {
    let find = function (layer, ns) {
      if (layer.layers != null) {
        for (var k in layer.layers) {
          var v = layer.layers[k];
          if (k === ns) {
            return layer;
          }
        }
        for (k in layer.layers) {
          var v = layer.layers[k];
          let r = find(v, ns);
          if (r != null) {
            return r;
          }
        }
      }
    };

    let layer = find(this.packet, e.item.ns);
    let range = [layer.payload.start, layer.payload.end];
    PubSub.pub('packet-view:range', range);
  };

  this.rangeOut = () => {
    PubSub.pub('packet-view:range', [0, 0]);
  };
</script>

<style type="text/less" scoped>
  :scope {
    -webkit-user-select: auto;
    table {
      width: 100%;
      align-self: stretch;
      border-spacing: 0;
      padding: 10px;
      td {
        cursor: default;
      }
    }
    .text-label {
      cursor: default;
    }
    .layer-name {
      white-space: nowrap;
      cursor: default;
      margin-left: 10px;
    }
    .text-summary {
      padding: 0 10px;
    }
    ul {
      padding-left: 20px;
    }
    li {
      white-space: nowrap;
      list-style: none;
    }
    i {
      font-style: normal;
    }
    i.base {
      font-weight: bold;
    }
    .label {
      margin: 0;
    }
    .fa-circle-o {
      opacity: 0.1;
    }
  }
</style>

</packet-view>
