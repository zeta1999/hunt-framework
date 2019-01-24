/*
 * Hunt - A high-level D Programming Language Web framework that encourages rapid development and clean, pragmatic design.
 *
 * Copyright (C) 2015-2019, HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */

module hunt.framework.view.View;

public import hunt.framework.view.Environment;
public import hunt.framework.view.Template;
public import hunt.framework.view.Util;
public import hunt.framework.view.Exception;

import hunt.framework.Simplify;

public import hunt.util.Serialize;
public import hunt.logging;

import std.json : JSONValue;
import std.path;

import hunt.framework.routing;

class View
{
    private
    {
        string _templatePath = "./views/";
        string _extName = ".html";
        Environment _env;
        string _routeGroup = DEFAULT_ROUTE_GROUP;
        JSONValue _context;
    }

    this(Environment env)
    {
        _templatePath = app().config().view.path;
        _extName = app().config().view.ext;

        _env = env;
    }

    public Environment env()
    {
        return _env;
    }

    public View setTemplatePath(string path)
    {
        _templatePath = path;
        _env.setTemplatePath(path);

        return this;
    }

    public View setTemplateExt(string fileExt)
    {
        _extName = fileExt;
        return this;
    }

    public string getTemplatePath()
    {
        return _templatePath;
    }

    public View setRouteGroup(string rg)
    {
        _routeGroup = rg;
        //if (_routeGroup != DEFAULT_ROUTE_GROUP)
        _env.setRouteGroup(rg);
        _env.setTemplatePath(buildNormalizedPath(_templatePath) ~ dirSeparator ~ _routeGroup);

        return this;
    }

    public View setLocale(string locale)
    {
        _env.setLocale(locale);
        return this;
    }

    public string render(string tempalteFile)
    {
        import std.stdio;
        version (HUNT_DEBUG) trace("---rend context :", _context.toString);
        return _env.renderFile(tempalteFile ~ _extName,_context);
    }

    public void assign(T)(string key, T t)
    {
        this.assign(key, toJson(t , app().config().view.arrayDepth));
    }

    public void assign(string key, JSONValue t)
    {
        _context[key] = t;
    }
}

__gshared private Environment _envInstance;

View GetViewObject()
{
    import hunt.framework.application.ApplicationConfig;
    if (_envInstance is null)
    {
        _envInstance = new Environment;
    }
    auto view = new View(_envInstance);

    view.setTemplatePath(app().config().view.path).setTemplateExt(app().config().view.ext);
    return view;
}
