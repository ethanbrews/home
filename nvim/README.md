Nvim config
---

## Commands

<table><thead>
    <tr>
        <th>Category</th>
        <th>Command</th>
        <th>Action</th>
    </tr>
<tbody>
    <tr>
        <td>Lazy Package Manager</td>
        <td>:Lazy</td>
        <td>Open the Lazy Package Manager window</td>
    </tr>
    <tr>
        <td>General</td>
        <td>:Vb</td>
        <td>Enter Visual Block Mode</td>
    </tr>
    <tr>
        <td rowspan="3">LSP</td>
        <td>:LspInfo</td>
        <td>Show LSP Info</td>
    </tr>
    <tr>
        <td>:LspInstall</td>
        <td>Install an LSP for the current language</td>
    </tr>
    <tr>
        <td>:LspUninstall &lt;name&gt;</td>
        <td>Uninstall a given LSP</td>
    </tr>
</tbody>


## Keys

<table><thead>
  <tr>
    <th>Category</th>
    <th>Keybind</th>
    <th>Action</th>
  </tr></thead>
<tbody>
  <tr>
    <td rowspan="13">Buffers</td>
    <td>tf</td>
    <td>Open Telescope Files Finder</td>
  </tr>
  <tr>
    <td>tg</td>
    <td>Open Telescope Live Grep</td>
  </tr>
  <tr>
    <td>to</td>
    <td>Open Oil in a new buffer</td>
  </tr>
  <tr>
    <td>tl</td>
    <td>Open Telescope Open Buffers</td>
  </tr>
  <tr>
    <td>tq</td>
    <td>Open Telescope Live Tags</td>
  </tr>
  <tr>
    <td>th</td>
    <td>Open Telescope File History</td>
  </tr>
  <tr>
    <td>t;</td>
    <td>Open Telescope Command History</td>
  </tr>
  <tr>
    <td>tm</td>
    <td>Open Telescope Live Marks</td>
  </tr>
  <tr>
    <td>tq</td>
    <td>Open Telescope Live Registers</td>
  </tr>
  <tr>
    <td>t/</td>
    <td>Open Telescope Man Search</td>
  </tr>
  <tr>
    <td>tn</td>
    <td>Next Buffer</td>
  </tr>
  <tr>
    <td>tp</td>
    <td>Previous Buffer</td>
  </tr>
  <tr>
    <td>td</td>
    <td>Close Buffer</td>
  </tr>
  <tr>
    <td rowspan="2">Comments</td>
    <td>&lt;Space&gt;cc</td>
    <td>Comment out current line or selection</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;cb</td>
    <td>Comment out current line or selection with a block comment</td>
  </tr>
  <tr>
    <td rowspan="6">Trouble Window</td>
    <td>\\xx</td>
    <td>Toggle diagnostics in trouble window</td>
  </tr>
  <tr>
    
    <td>\\xX</td>
    <td>Trouble diagnostics in buffer</td>
  </tr>
  <tr>
    
    <td>\\xL</td>
    <td>Toggle loclist in trouble window</td>
  </tr>
  <tr>
    
    <td>\\xQ</td>
    <td>Toggle qflist in trouble window</td>
  </tr>
  <tr>
    
    <td>\\cs</td>
    <td>Toggle trouble symbols window</td>
  </tr>
  <tr>
    
    <td>\\cl</td>
    <td>Trouble symbols buffer</td>
  </tr>
  <tr>
    <td rowspan="2">Git (Navigation)</td>
    <td>\\gj</td>
    <td>Next Git Hunk</td>
  </tr>
  <tr>
    
    <td>\\gk</td>
    <td>Previous Git Hunk</td>
  </tr>
  <tr>
    <td rowspan="5">Git (Actions)</td>
    <td>\\gs</td>
    <td>Stage Hunk or Selection</td>
  </tr>
  <tr>
    
    <td>\\gr</td>
    <td>Reset Hunk or Selection</td>
  </tr>
  <tr>
    
    <td>\\gu</td>
    <td>Undo Stage Hunk</td>
  </tr>
  <tr>
    
    <td>\\gp</td>
    <td>Preview Hunk</td>
  </tr>
  <tr>
    
    <td>\\gb</td>
    <td>Blame Line</td>
  </tr>
  <tr>
    <td rowspan="2">Git (Diff)</td>
    <td>\\gd</td>
    <td>Diff this buffer</td>
  </tr>
  <tr>
    <td>\\gD</td>
    <td>Diff this buffer against HEAD~1</td>
  </tr>
  <tr>
    <td rowspan="4">Navigation (Hop)</td>
    <td>\\f</td>
    <td>Walk Forwards</td>
  </tr>
  <tr>
    
    <td>\\F</td>
    <td>Walk Backwards</td>
  </tr>
  <tr>
    
    <td>\\w</td>
    <td>Walk Forwards on the current line</td>
  </tr>
  <tr>
    
    <td>\\b</td>
    <td>Walk Backwards on the current line</td>
  </tr>
  <tr>
    <td rowspan="6">Code Editing</td>
    <td>&lt;Space&gt;m</td>
    <td>Toggle split/join block of code</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;j</td>
    <td>Join block of code</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;s</td>
    <td>Split block of code</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;M</td>
    <td>Toggle split/join block of code recursively</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;J</td>
    <td>Join block of code recursively</td>
  </tr>
  <tr>
    
    <td>&lt;Space&gt;S</td>
    <td>Split block of code recursively</td>
  </tr>
</tbody></table>
