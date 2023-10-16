<!DOCTYPE html>

<html lang="en">
<head>
<meta charset="utf8"/>
<meta content="width=device-width, initial-scale=1" name="viewport"/>
<title>~technomancy/better-defaults: better-defaults.el - sourcehut git</title>
<link href="/static/logo.svg" rel="icon" type="image/svg+xml"/>
<link href="/static/logo.png" rel="icon" sizes="any" type="image/png"/>
<link href="/static/main.min.a7e88522.css" rel="stylesheet"/>
<style>
pre {
  tab-size: 8
}
</style>
<meta content="git" name="vcs"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults" name="vcs:clone"/>
<meta content="git@git.sr.ht:~technomancy/better-defaults" name="vcs:clone"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults" name="forge:summary"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults/tree/{ref}/{path}" name="forge:dir"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults/tree/{ref}/{path}" name="forge:file"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults/blob/{ref}/{path}" name="forge:rawfile"/>
<meta content="https://git.sr.ht/~technomancy/better-defaults/tree/{ref}/{path}#L{line}" name="forge:line"/>
<meta content="git.sr.ht/~technomancy/better-defaults git https://git.sr.ht/~technomancy/better-defaults" name="go-import"/>
</head>
<body>
<nav class="navbar navbar-light navbar-expand-sm">
<span class="navbar-brand">
<span aria-hidden="true" class="icon icon-circle"><svg height="22" viewbox="0 0 512 512" width="22" xmlns="http://www.w3.org/2000/svg"><path d="M256 8C119 8 8 119 8 256s111 248 248 248 248-111 248-248S393 8 256 8zm0 448c-110.5 0-200-89.5-200-200S145.5 56 256 56s200 89.5 200 200-89.5 200-200 200z"></path></svg>
</span>
<a href="https://sr.ht">
    sourcehut
  </a>
</span>
<ul class="navbar-nav">
</ul>
<div class="login">
<span class="navbar-text">
<a href="https://meta.sr.ht/oauth/authorize?client_id=25ff6e5ce60d7345&amp;scopes=profile,keys,b99a95de3e69c958/jobs:write&amp;state=%2F~technomancy%2Fbetter-defaults%2Ftree%2Fmain%2Fitem%2Fbetter-defaults.el%3F" rel="nofollow">Log in</a>
    —
    <a href="https://meta.sr.ht">Register</a>
</span>
</div>
</nav>
<div class="header-tabbed">
<div class="container-fluid">
<h2>
<a href="/~technomancy/">~technomancy</a>/<wbr/>better-defaults
    </h2>
<ul class="nav nav-tabs">
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults">summary</a>
</li>
<li class="nav-item">
<a class="nav-link active" href="/~technomancy/better-defaults/tree">tree</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/log">log</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/refs">refs</a>
</li>
</ul>
</div>
</div>
<div class="header-extension" style="margin-bottom: 0;">
<div class="blob container-fluid">
<span>
<a href="/~technomancy/better-defaults/tree/main">better-defaults</a>/better-defaults.el



  
  
  <span class="text-muted" style="margin-left: 1rem">
<span title="100644">
      -rw-r--r--
    </span>
</span>
<span class="text-muted" style="margin-left: 1rem">
<span title="3381 bytes">
        3.3 KiB
      </span>
</span>
<div class="blob-nav" style="margin-left: 1rem">
<ul class="nav nav-tabs">
<li class="nav-item">
<a class="nav-link active" href="/~technomancy/better-defaults/tree/main/item/better-defaults.el">View</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/log/main/item/better-defaults.el">Log</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/blame/main/better-defaults.el">Blame</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/blob/main/better-defaults.el" rel="noopener noreferrer nofollow">View raw</a>
</li>
<li class="nav-item">
<a class="nav-link" href="/~technomancy/better-defaults/tree/7d0e56b3a7f84bea6ee2dd9fda09da9df335f89e/item/better-defaults.el">Permalink</a>
</li>
</ul>
</div>
</span>
<div class="commit">
<a href="/~technomancy/better-defaults/commit/main">7d0e56b3</a> —
      
      
      <a href="/~eskin/">Jon Eskin</a>
      
      use bound-and-true-p to check if fido-vertical-mode is enabled
      <span class="text-muted">
<span title="2023-05-25 08:23:19 UTC">4 months ago</span>
</span>
</div>
<div class="clearfix"></div>
</div>
</div>
<div class="container-fluid code-viewport">
<div class="row" style="margin-right: 0;">
<div class="col-md-12 code-view">
<pre class="ruler"><span>                                                                                </span></pre>
<pre class="lines"><a href="#L1" id="L1">1</a>
<a href="#L2" id="L2">2</a>
<a href="#L3" id="L3">3</a>
<a href="#L4" id="L4">4</a>
<a href="#L5" id="L5">5</a>
<a href="#L6" id="L6">6</a>
<a href="#L7" id="L7">7</a>
<a href="#L8" id="L8">8</a>
<a href="#L9" id="L9">9</a>
<a href="#L10" id="L10">10</a>
<a href="#L11" id="L11">11</a>
<a href="#L12" id="L12">12</a>
<a href="#L13" id="L13">13</a>
<a href="#L14" id="L14">14</a>
<a href="#L15" id="L15">15</a>
<a href="#L16" id="L16">16</a>
<a href="#L17" id="L17">17</a>
<a href="#L18" id="L18">18</a>
<a href="#L19" id="L19">19</a>
<a href="#L20" id="L20">20</a>
<a href="#L21" id="L21">21</a>
<a href="#L22" id="L22">22</a>
<a href="#L23" id="L23">23</a>
<a href="#L24" id="L24">24</a>
<a href="#L25" id="L25">25</a>
<a href="#L26" id="L26">26</a>
<a href="#L27" id="L27">27</a>
<a href="#L28" id="L28">28</a>
<a href="#L29" id="L29">29</a>
<a href="#L30" id="L30">30</a>
<a href="#L31" id="L31">31</a>
<a href="#L32" id="L32">32</a>
<a href="#L33" id="L33">33</a>
<a href="#L34" id="L34">34</a>
<a href="#L35" id="L35">35</a>
<a href="#L36" id="L36">36</a>
<a href="#L37" id="L37">37</a>
<a href="#L38" id="L38">38</a>
<a href="#L39" id="L39">39</a>
<a href="#L40" id="L40">40</a>
<a href="#L41" id="L41">41</a>
<a href="#L42" id="L42">42</a>
<a href="#L43" id="L43">43</a>
<a href="#L44" id="L44">44</a>
<a href="#L45" id="L45">45</a>
<a href="#L46" id="L46">46</a>
<a href="#L47" id="L47">47</a>
<a href="#L48" id="L48">48</a>
<a href="#L49" id="L49">49</a>
<a href="#L50" id="L50">50</a>
<a href="#L51" id="L51">51</a>
<a href="#L52" id="L52">52</a>
<a href="#L53" id="L53">53</a>
<a href="#L54" id="L54">54</a>
<a href="#L55" id="L55">55</a>
<a href="#L56" id="L56">56</a>
<a href="#L57" id="L57">57</a>
<a href="#L58" id="L58">58</a>
<a href="#L59" id="L59">59</a>
<a href="#L60" id="L60">60</a>
<a href="#L61" id="L61">61</a>
<a href="#L62" id="L62">62</a>
<a href="#L63" id="L63">63</a>
<a href="#L64" id="L64">64</a>
<a href="#L65" id="L65">65</a>
<a href="#L66" id="L66">66</a>
<a href="#L67" id="L67">67</a>
<a href="#L68" id="L68">68</a>
<a href="#L69" id="L69">69</a>
<a href="#L70" id="L70">70</a>
<a href="#L71" id="L71">71</a>
<a href="#L72" id="L72">72</a>
<a href="#L73" id="L73">73</a>
<a href="#L74" id="L74">74</a>
<a href="#L75" id="L75">75</a>
<a href="#L76" id="L76">76</a>
<a href="#L77" id="L77">77</a>
<a href="#L78" id="L78">78</a>
<a href="#L79" id="L79">79</a>
<a href="#L80" id="L80">80</a>
<a href="#L81" id="L81">81</a>
<a href="#L82" id="L82">82</a>
<a href="#L83" id="L83">83</a>
<a href="#L84" id="L84">84</a>
<a href="#L85" id="L85">85</a>
<a href="#L86" id="L86">86</a>
<a href="#L87" id="L87">87</a>
<a href="#L88" id="L88">88</a>
<a href="#L89" id="L89">89</a>
<a href="#L90" id="L90">90</a>
<a href="#L91" id="L91">91</a>
<a href="#L92" id="L92">92</a>
<a href="#L93" id="L93">93</a>
<a href="#L94" id="L94">94</a>
<a href="#L95" id="L95">95</a>
<a href="#L96" id="L96">96</a></pre>
<div class="highlight"><pre><span></span><span class="c1">;;; better-defaults.el --- Fixing weird quirks and poor defaults</span><span class="w"></span>

<span class="c1">;; Copyright © 2013-2020 Phil Hagelberg and contributors</span><span class="w"></span>

<span class="c1">;; Author: Phil Hagelberg</span><span class="w"></span>
<span class="c1">;; URL: https://github.com/technomancy/better-defaults</span><span class="w"></span>
<span class="c1">;; Version: 0.1.4</span><span class="w"></span>
<span class="c1">;; Package-Requires: ((emacs "25.1"))</span><span class="w"></span>
<span class="c1">;; Created: 2013-04-16</span><span class="w"></span>
<span class="c1">;; Keywords: convenience</span><span class="w"></span>

<span class="c1">;; This file is NOT part of GNU Emacs.</span><span class="w"></span>

<span class="c1">;;; Commentary:</span><span class="w"></span>

<span class="c1">;; There are a number of unfortunate facts about the way Emacs works</span><span class="w"></span>
<span class="c1">;; out of the box.  While all users will eventually need to learn their</span><span class="w"></span>
<span class="c1">;; way around in order to customize it to their particular tastes,</span><span class="w"></span>
<span class="c1">;; this package attempts to address the most obvious of deficiencies</span><span class="w"></span>
<span class="c1">;; in uncontroversial ways that nearly everyone can agree upon.</span><span class="w"></span>

<span class="c1">;; Obviously there are many further tweaks you could do to improve</span><span class="w"></span>
<span class="c1">;; Emacs, (like those the Starter Kit and similar packages) but this</span><span class="w"></span>
<span class="c1">;; package focuses only on those that have near-universal appeal.</span><span class="w"></span>

<span class="c1">;;; License:</span><span class="w"></span>

<span class="c1">;; This program is free software; you can redistribute it and/or modify</span><span class="w"></span>
<span class="c1">;; it under the terms of the GNU General Public License as published by</span><span class="w"></span>
<span class="c1">;; the Free Software Foundation; either version 3, or (at your option)</span><span class="w"></span>
<span class="c1">;; any later version.</span><span class="w"></span>
<span class="c1">;;</span><span class="w"></span>
<span class="c1">;; This program is distributed in the hope that it will be useful,</span><span class="w"></span>
<span class="c1">;; but WITHOUT ANY WARRANTY; without even the implied warranty of</span><span class="w"></span>
<span class="c1">;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the</span><span class="w"></span>
<span class="c1">;; GNU General Public License for more details.</span><span class="w"></span>
<span class="c1">;;</span><span class="w"></span>
<span class="c1">;; You should have received a copy of the GNU General Public License</span><span class="w"></span>
<span class="c1">;; along with GNU Emacs; see the file COPYING.  If not, write to the</span><span class="w"></span>
<span class="c1">;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,</span><span class="w"></span>
<span class="c1">;; Boston, MA 02110-1301, USA.</span><span class="w"></span>

<span class="c1">;;; Code:</span><span class="w"></span>

<span class="p">(</span><span class="k">progn</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nb">unless</span><span class="w"> </span><span class="p">(</span><span class="k">or</span><span class="w"> </span><span class="p">(</span><span class="nf">fboundp</span><span class="w"> </span><span class="ss">'helm-mode</span><span class="p">)</span><span class="w"> </span><span class="p">(</span><span class="nf">fboundp</span><span class="w"> </span><span class="ss">'ivy-mode</span><span class="p">)</span><span class="w"> </span><span class="p">(</span><span class="nv">bound-and-true-p</span><span class="w"> </span><span class="nv">fido-vertical-mode</span><span class="p">))</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="nv">ido-mode</span><span class="w"> </span><span class="no">t</span><span class="p">)</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="k">setq</span><span class="w"> </span><span class="nv">ido-enable-flex-matching</span><span class="w"> </span><span class="no">t</span><span class="p">))</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nb">unless</span><span class="w"> </span><span class="p">(</span><span class="nf">memq</span><span class="w"> </span><span class="nf">window-system</span><span class="w"> </span><span class="o">'</span><span class="p">(</span><span class="nv">mac</span><span class="w"> </span><span class="nv">ns</span><span class="p">))</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="nv">menu-bar-mode</span><span class="w"> </span><span class="mi">-1</span><span class="p">))</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nb">when</span><span class="w"> </span><span class="p">(</span><span class="nf">fboundp</span><span class="w"> </span><span class="ss">'tool-bar-mode</span><span class="p">)</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="nv">tool-bar-mode</span><span class="w"> </span><span class="mi">-1</span><span class="p">))</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nb">when</span><span class="w"> </span><span class="p">(</span><span class="nf">fboundp</span><span class="w"> </span><span class="ss">'scroll-bar-mode</span><span class="p">)</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="nv">scroll-bar-mode</span><span class="w"> </span><span class="mi">-1</span><span class="p">))</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nb">when</span><span class="w"> </span><span class="p">(</span><span class="nf">fboundp</span><span class="w"> </span><span class="ss">'horizontal-scroll-bar-mode</span><span class="p">)</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="nv">horizontal-scroll-bar-mode</span><span class="w"> </span><span class="mi">-1</span><span class="p">))</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nf">autoload</span><span class="w"> </span><span class="ss">'zap-up-to-char</span><span class="w"> </span><span class="s">"misc"</span><span class="w"></span>
<span class="w">    </span><span class="s">"Kill up to, but not including ARGth occurrence of CHAR."</span><span class="w"> </span><span class="no">t</span><span class="p">)</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nb">require</span><span class="w"> </span><span class="ss">'uniquify</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="k">setq</span><span class="w"> </span><span class="nv">uniquify-buffer-name-style</span><span class="w"> </span><span class="ss">'forward</span><span class="p">)</span><span class="w"></span>

<span class="w">  </span><span class="c1">;; https://www.emacswiki.org/emacs/SavePlace</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">save-place-mode</span><span class="w"> </span><span class="mi">1</span><span class="p">)</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"M-/"</span><span class="p">)</span><span class="w"> </span><span class="ss">'hippie-expand</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"C-x C-b"</span><span class="p">)</span><span class="w"> </span><span class="ss">'ibuffer</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"M-z"</span><span class="p">)</span><span class="w"> </span><span class="ss">'zap-up-to-char</span><span class="p">)</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"C-s"</span><span class="p">)</span><span class="w"> </span><span class="ss">'isearch-forward-regexp</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"C-r"</span><span class="p">)</span><span class="w"> </span><span class="ss">'isearch-backward-regexp</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"C-M-s"</span><span class="p">)</span><span class="w"> </span><span class="ss">'isearch-forward</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">global-set-key</span><span class="w"> </span><span class="p">(</span><span class="nv">kbd</span><span class="w"> </span><span class="s">"C-M-r"</span><span class="p">)</span><span class="w"> </span><span class="ss">'isearch-backward</span><span class="p">)</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nv">show-paren-mode</span><span class="w"> </span><span class="mi">1</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="k">setq-default</span><span class="w"> </span><span class="nv">indent-tabs-mode</span><span class="w"> </span><span class="no">nil</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="nv">savehist-mode</span><span class="w"> </span><span class="mi">1</span><span class="p">)</span><span class="w"></span>
<span class="w">  </span><span class="p">(</span><span class="k">setq</span><span class="w"> </span><span class="nv">save-interprogram-paste-before-kill</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">apropos-do-all</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">mouse-yank-at-point</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">require-final-newline</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">visible-bell</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">load-prefer-newer</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">backup-by-copying</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">frame-inhibit-implied-resize</span><span class="w"> </span><span class="no">t</span><span class="w"></span>
<span class="w">        </span><span class="nv">ediff-window-setup-function</span><span class="w"> </span><span class="ss">'ediff-setup-windows-plain</span><span class="w"></span>
<span class="w">        </span><span class="nv">custom-file</span><span class="w"> </span><span class="p">(</span><span class="nf">expand-file-name</span><span class="w"> </span><span class="s">"custom.el"</span><span class="w"> </span><span class="nv">user-emacs-directory</span><span class="p">))</span><span class="w"></span>

<span class="w">  </span><span class="p">(</span><span class="nb">unless</span><span class="w"> </span><span class="nv">backup-directory-alist</span><span class="w"></span>
<span class="w">    </span><span class="p">(</span><span class="k">setq</span><span class="w"> </span><span class="nv">backup-directory-alist</span><span class="w"> </span><span class="o">`</span><span class="p">((</span><span class="s">"."</span><span class="w"> </span><span class="o">.</span><span class="w"> </span><span class="o">,</span><span class="p">(</span><span class="nf">concat</span><span class="w"> </span><span class="nv">user-emacs-directory</span><span class="w"></span>
<span class="w">                                                   </span><span class="s">"backups"</span><span class="p">))))))</span><span class="w"></span>

<span class="p">(</span><span class="nb">provide</span><span class="w"> </span><span class="ss">'better-defaults</span><span class="p">)</span><span class="w"></span>
<span class="c1">;;; better-defaults.el ends here</span><span class="w"></span>
</pre></div>
</div>
</div>
<script src="/static/linelight.js"></script>
</div></body>
</html>